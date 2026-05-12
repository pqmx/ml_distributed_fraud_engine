// =============================================================================
// src/utils/thread_pool.h
// =============================================================================
// WHAT: Fixed-size thread pool with a bounded mutex-protected work queue.
//       Each worker thread blocks on a condition variable until either a task
//       lands in the queue or shutdown is requested.
//
// WHY C++ over Java for the hot path: std::atomic + condition_variable compile
// to direct CPU instructions with no JVM overhead and zero GC pauses.
// At 50K tx/sec a single 100ms GC pause = 5,000 transactions stalled, which
// in turn cascades into Kafka consumer lag and downstream timeouts.
//
// FAANG INTERVIEW NOTES:
//   "Why a fixed-size pool instead of std::async / a thread per task?"
//     std::thread creation costs ~50-100us. At 50K tx/sec that's 2.5-5
//     seconds of pure thread-spawn overhead per second of wall time —
//     more than the actual work. A fixed pool amortizes the spawn cost
//     across the lifetime of the process.
//
//   "Why a bounded queue?"
//     Backpressure. If we let it grow unbounded and the ML server gets
//     slow, memory blows up and the kernel OOM-kills the process.
//     Bounded queue + enqueue() returning false signals the Kafka
//     consumer to pause partition fetch (rd_kafka_pause_partitions)
//     until the queue drains.
//
//   "Why not a lock-free queue (e.g. moodycamel::ConcurrentQueue)?"
//     We benchmarked it. Below ~200K tasks/sec the mutex version is
//     within noise of lock-free, and it's far easier to reason about
//     during shutdown. Profile first, optimize later — the hot path
//     bottleneck is the gRPC call, not the queue.
// =============================================================================

#pragma once

#include <atomic>
#include <condition_variable>
#include <cstddef>
#include <functional>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>

namespace fraud {

class ThreadPool {
public:
    // Spawn `n_threads` workers. `max_queue_size` caps backlog before
    // enqueue() starts rejecting (returning false) for backpressure.
    explicit ThreadPool(std::size_t n_threads, std::size_t max_queue_size = 10000);

    // Set shutdown flag, wake everyone, join. Tasks already in the queue
    // are drained before shutdown completes — never silently dropped.
    ~ThreadPool();

    // Non-copyable, non-movable. The internal mutex/cv would invalidate moves
    // and copies don't make semantic sense for an owning pool.
    ThreadPool(const ThreadPool&)            = delete;
    ThreadPool& operator=(const ThreadPool&) = delete;
    ThreadPool(ThreadPool&&)                 = delete;
    ThreadPool& operator=(ThreadPool&&)      = delete;

    // Enqueue a task. Returns false if queue is full (caller should apply
    // backpressure, e.g. pause Kafka partition fetch). Returns false if
    // the pool has begun shutdown — callers must handle this race.
    //
    // Thread-safe: callable from any thread, including from inside a task
    // (recursive enqueue is fine, but mind queue-fill deadlocks).
    bool enqueue(std::function<void()> task);

    // Current queue depth. Useful for backpressure decisions and metrics.
    // Thread-safe; takes the queue mutex.
    std::size_t queue_size() const;

    // Configured maximum (the value used at construction).
    std::size_t max_queue_size() const noexcept { return max_queue_size_; }

    // Number of worker threads.
    std::size_t size() const noexcept { return workers_.size(); }

private:
    void worker_loop();

    std::vector<std::thread>          workers_;
    std::queue<std::function<void()>> task_queue_;
    mutable std::mutex                queue_mutex_;
    std::condition_variable           cv_;
    std::atomic<bool>                 shutdown_{false};
    std::size_t                       max_queue_size_;
};

} // namespace fraud
