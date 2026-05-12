// =============================================================================
// tests/test_thread_pool.cpp
// =============================================================================
// Unit tests for the ThreadPool. These actually run — the pool is fully
// implemented, not a skeleton.
//
// What we cover:
//   - basic enqueue + execute
//   - bounded queue rejects when full
//   - shutdown drains in-flight work
//   - parallelism (multiple workers actually run concurrently)
//   - exception in a task doesn't kill the pool
// =============================================================================

#include "utils/thread_pool.h"

#include <gtest/gtest.h>

#include <atomic>
#include <chrono>
#include <thread>
#include <vector>

using namespace std::chrono_literals;

TEST(ThreadPool, ExecutesEnqueuedTasks) {
    fraud::ThreadPool pool(4);

    std::atomic<int> counter{0};
    constexpr int N = 1000;

    for (int i = 0; i < N; ++i) {
        ASSERT_TRUE(pool.enqueue([&counter] {
            counter.fetch_add(1, std::memory_order_relaxed);
        }));
    }

    // Pool destructor drains remaining work, but we want to assert
    // before destruction so we know the count is right under load.
    // Spin briefly with a timeout.
    auto deadline = std::chrono::steady_clock::now() + 5s;
    while (counter.load() < N && std::chrono::steady_clock::now() < deadline) {
        std::this_thread::sleep_for(1ms);
    }

    EXPECT_EQ(counter.load(), N);
}

TEST(ThreadPool, BoundedQueueRejectsWhenFull) {
    // Tiny queue, slow tasks → easy to fill.
    fraud::ThreadPool pool(/*n_threads=*/1, /*max_queue_size=*/2);

    // Block the single worker so our enqueues stack up in the queue.
    std::atomic<bool> release{false};
    pool.enqueue([&release] {
        while (!release.load()) std::this_thread::sleep_for(1ms);
    });

    // Now the worker is busy; we can fill exactly max_queue_size more.
    EXPECT_TRUE(pool.enqueue([] {}));
    EXPECT_TRUE(pool.enqueue([] {}));

    // Third one should be rejected. Note: there's a tiny race where the
    // worker grabs an item from the queue right before this enqueue runs,
    // freeing a slot. Try a couple times in a tight loop and require at
    // least one rejection — that's the contract we care about.
    bool saw_rejection = false;
    for (int i = 0; i < 5; ++i) {
        if (!pool.enqueue([] {})) { saw_rejection = true; break; }
    }
    EXPECT_TRUE(saw_rejection);

    release.store(true);
}

TEST(ThreadPool, ShutdownDrainsInflightTasks) {
    std::atomic<int> ran{0};
    constexpr int N = 200;

    {
        fraud::ThreadPool pool(4);
        for (int i = 0; i < N; ++i) {
            ASSERT_TRUE(pool.enqueue([&ran] {
                std::this_thread::sleep_for(1ms);
                ran.fetch_add(1, std::memory_order_relaxed);
            }));
        }
        // Pool destructor here: must drain all 200 before joining.
    }

    EXPECT_EQ(ran.load(), N) << "shutdown silently dropped tasks";
}

TEST(ThreadPool, ActuallyRunsInParallel) {
    constexpr int kThreads = 4;
    fraud::ThreadPool pool(kThreads);

    std::atomic<int> active{0};
    std::atomic<int> peak{0};
    std::atomic<bool> release{false};

    for (int i = 0; i < kThreads; ++i) {
        pool.enqueue([&] {
            int now = active.fetch_add(1, std::memory_order_relaxed) + 1;
            // record high-water mark
            int prev = peak.load(std::memory_order_relaxed);
            while (now > prev &&
                   !peak.compare_exchange_weak(prev, now,
                                               std::memory_order_relaxed)) {}
            // hold the worker until release flag flips
            while (!release.load(std::memory_order_acquire)) {
                std::this_thread::sleep_for(100us);
            }
            active.fetch_sub(1, std::memory_order_relaxed);
        });
    }

    // Wait for all 4 to be in flight (or time out).
    auto deadline = std::chrono::steady_clock::now() + 1s;
    while (peak.load() < kThreads &&
           std::chrono::steady_clock::now() < deadline) {
        std::this_thread::sleep_for(1ms);
    }

    EXPECT_EQ(peak.load(), kThreads) << "workers didn't run concurrently";
    release.store(true, std::memory_order_release);
}

TEST(ThreadPool, ExceptionInTaskDoesNotKillWorker) {
    fraud::ThreadPool pool(1);

    pool.enqueue([] { throw std::runtime_error("boom"); });

    // If the worker survived, the next task should still run.
    std::atomic<bool> ran_after{false};
    pool.enqueue([&ran_after] { ran_after.store(true); });

    auto deadline = std::chrono::steady_clock::now() + 1s;
    while (!ran_after.load() &&
           std::chrono::steady_clock::now() < deadline) {
        std::this_thread::sleep_for(1ms);
    }
    EXPECT_TRUE(ran_after.load());
}
