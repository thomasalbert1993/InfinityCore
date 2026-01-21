//
//  Async.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 21/01/2026.
//

import Foundation

/// This suite of helpers is primarily intended for testing purposes.
///
/// It helps ensure that asynchronous tests do not run indefinitely due to implementation issues
/// such as infinite loops, stalled tasks, or unexpectedly long operations (e.g. unintended network calls).
///
/// By enforcing execution within a bounded timeout, these helpers guarantee test termination
/// and cause tests to fail deterministically when expected events never occur.

/// An error thrown when asynchronous tasks did not complete before a given timeout.
public struct AsyncTimeoutError: Error {
}

/// Performs an async task, secured with a timeout.
///
/// - Parameter timeout: The task timeout (defaults to 2 seconds).
/// - Parameter task: The asynchronous task to perform.
///
/// - Returns: The result of the task.
///
/// - Throws: Throws an `AsyncTimeoutError` is task did not complete before the timeout.
@MainActor
public func withTimeout<T: Sendable>(_ timeout: TimeInterval = 2.0, task: @MainActor @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        
        group.addTask {
            try await task()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            throw AsyncTimeoutError()
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

/// Waits for a completion handler to be executed, secured with a timeout.
///
/// - Parameter timeout: The task timeout (defaults to 2 seconds).
/// - Parameter body: The task to perform. A completion handler is provided and must be called
/// within the max given time or an `AsyncTimeoutError` will be thrown.
///
/// - Returns: The result of the executed completion.
///
/// - Throws: Throws an `AsyncTimeoutError` is task did not complete before the timeout.
@MainActor
public func awaitCompletion<T: Sendable>(timeout: TimeInterval = 2.0, _ body: @MainActor @escaping (@escaping (T) -> Void) -> Void) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
        var resumed = false
        
        func resumeOnce(_ result: Result<T, Error>) {
            guard !resumed else { return }
            resumed = true
            continuation.resume(with: result)
        }
        
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            resumeOnce(.failure(AsyncTimeoutError()))
        }
        
        body { value in
            timeoutTask.cancel()
            resumeOnce(.success(value))
        }
        
        Task { // cancellation safety
            await Task.yield()
            if Task.isCancelled {
                timeoutTask.cancel()
                resumeOnce(.failure(CancellationError()))
            }
        }
    }
}
