//
//  AsyncTimoutTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 21/01/2026.
//

import Foundation
import Testing
@testable import InfinityCore

struct AsyncTimoutTests {
    
    
    //---------------------
    // MARK: withTimeout()
    //---------------------
    
    @Test("withTimeout() returns value when task finishes before timeout") func withTimeoutReturnsValue() async throws {
        
        let value = try await withTimeout(1.0) {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            return 42
        }
        
        #expect(value == 42)
    }
    
    @Test("withTimeout() throws AsyncTimeoutError when task exceeds timeout") func withTimeoutThrowsTimeoutError() async {
        
        await #expect(throws: AsyncTimeoutError.self) {
            try await withTimeout(0.1) {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1s
                return 0
            }
        }
    }
    
    @Test("withTimeout() propagates task error") func withTimeoutPropagatesError() async {
        
        struct TestError: Error {}
        
        await #expect(throws: TestError.self) {
            try await withTimeout {
                throw TestError()
            }
        }
    }

    //-------------------------
    // MARK: awaitCompletion()
    //-------------------------
    
    @Test("awaitCompletion() returns value when completion is called") func awaitCompletionReturnsValue() async throws {
        
        let value = try await awaitCompletion { completion in
            completion(123)
        }
        
        #expect(value == 123)
    }
    
    @Test("awaitCompletion() throws AsyncTimeoutError when completion is never called") func awaitCompletionThrowsTimeout() async {
        
        await #expect(throws: AsyncTimeoutError.self) {
            let _: Int = try await awaitCompletion(timeout: 0.1) { _ in
                // Intentionally do nothing
            }
        }
    }
    
    @Test("awaitCompletion() ignores multiple completion calls") func awaitCompletionIgnoresMultipleCalls() async throws {
        
        let value = try await awaitCompletion { completion in
            completion(1)
            completion(2)
            completion(3)
        }
        
        #expect(value == 1)
    }
    
    @Test("awaitCompletion() ignores late completion after timeout") func awaitCompletionIgnoresLateCompletion() async {
        
        await #expect(throws: AsyncTimeoutError.self) {
            try await awaitCompletion(timeout: 0.1) { completion in
                Task {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                    completion(99)
                }
            }
        }
    }
}
