// =============================================================================
// src/utils/thread_pool.cpp
// =============================================================================
// Implementation of the fixed-size thread pool. See thread_pool.h for the
// design rationale and FAANG interview talking points.
// =============================================================================

#include "thread_pool.h"

#include <spdlog/spdlog.h>

#include <utility>

namespace fraud {

ThreadPool::ThreadPool(std::size_t n_threads, std::size_t max_queue_size)
    : max_queue_size_(max_queue_size) {
    if (n_threads == 0) {
        // Defensive default: 1 worker. Zero-thread pools are never what callers want.
        spdlog::warn("ThreadPool: n_threads=0 requested, using 1");
        n_threads = 1;
    } 

    workers_.reserve(n_threads);
    for (std::size_t i = 0; i < n_threads; ++i) {
        workers_.emplace_back([this] { worker_loop(); });
    }
    spdlog::info("ThreadPool: started {} workers, max_queue={}",
                 n_threads, max_queue_size_);
}

ThreadPool::~ThreadPool() {
    // Shutdown sequence:
    //  1. Flip the shutdown flag (atomic, lock-free read on the worker side).
    //  2. notify_all so every blocked worker wakes and re-checks the predicate.
    //  3. join. Workers drain remaining queued tasks before exiting — see worker_loop.
    {
        std::lock_guard<std::mutex> lock(queue_mutex_);
        shutdown_.store(true, std::memory_order_release);
    }
    cv_.notify_all();

    for (auto& t : workers_) {
        if (t.joinable()) t.join();
    }
    spdlog::info("ThreadPool: all workers joined cleanly");
}

bool ThreadPool::enqueue(std::function<void()> task) {
    {
        std::lock_guard<std::mutex> lock(queue_mutex_);

        // Reject after shutdown begins. The race here is benign: once
        // shutdown is set, dropping the task is correct — the caller
        // shouldn't be enqueuing anyway, and worker_loop will drain
        // whatever's already in the queue.
        if (shutdown_.load(std::memory_order_acquire)) return false;

        // Bounded queue: signal backpressure to caller instead of blowing memory.
        if (task_queue_.size() >= max_queue_size_) return false;

        task_queue_.push(std::move(task));
    }
    cv_.notify_one();   // Wake exactly one worker. notify_all would cause thundering herd.
    return true;
}

std::size_t ThreadPool::queue_size() const {
    std::lock_guard<std::mutex> lock(queue_mutex_);
    return task_queue_.size();
}

void ThreadPool::worker_loop() {
    for (;;) {
        std::function<void()> task;

        {
            std::unique_lock<std::mutex> lock(queue_mutex_);

            // Wait until: (a) we have work, OR (b) shutdown was requested.
            // Using a predicate handles spurious wakeups for free.
            cv_.wait(lock, [this] {
                return shutdown_.load(std::memory_order_acquire)
                    || !task_queue_.empty();
            });

            // Drain semantics: only exit when shutdown AND the queue is empty.
            // This guarantees no enqueued task is silently dropped.
            if (shutdown_.load(std::memory_order_acquire) && task_queue_.empty()) {
                return;
            }

            task = std::move(task_queue_.front());
            task_queue_.pop();
        }

        // Run the task with the lock released — the whole point of the pool.
        // Catch everything: a stray exception escaping the worker would
        // call std::terminate and kill the process. Log and keep serving.
        try {
            task();
        } catch (const std::exception& e) {
            spdlog::error("ThreadPool: task threw exception: {}", e.what());
        } catch (...) {
            spdlog::error("ThreadPool: task threw unknown exception");
        }
    }
}

} // namespace fraud
