//
//  DictionaryTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct DictionaryTests {
    
    @Test("Test mapKeys transforms keys correctly") func testMapKeys() {
        
        let mapped = simpleDict.mapKeys { $0.uppercased() }
        
        #expect(mapped == ["A": 1, "B": 2, "C": 3])
    }

    @Test("Test mapKeys can throw") func testMapKeysThrowing() {
        
        struct TestError: Error {}
        
        #expect(throws: TestError.self) {
            _ = try simpleDict.mapKeys { key in
                if key == "b" { throw TestError() }
                return key
            }
        }
    }
    
    @Test("Test compactMapKeys transforms keys and removes nils") func testCompactMapKeys() {
        
        let mapped = simpleDict.compactMapKeys { key -> String? in
            key == "b" ? nil : key.uppercased()
        }

        #expect(mapped == ["A": 1, "C": 3])
    }
    
    @Test("Test compactMapKeys can throw") func testCompactMapKeysThrowing() {
        
        struct TestError: Error {}
        
        #expect(throws: TestError.self) {
            _ = try simpleDict.compactMapKeys { key -> String? in
                if key == "c" { throw TestError() }
                return key.uppercased()
            }
        }
    }
    
    @Test("mapKeys on empty dictionary returns empty dictionary") func testMapKeysEmpty() {
        
        let empty: [String:Int] = [:]
        
        #expect(empty.mapKeys { $0.uppercased() } == [:])
    }
    
    @Test("compactMapKeys on empty dictionary returns empty dictionary") func testCompactMapKeysEmpty() {
        
        let empty: [String:Int] = [:]
        
        #expect(empty.compactMapKeys { _ in nil } == [:])
    }

    @Test("mapKeys identity returns same values") func testMapKeysIdentity() {
        
        let mapped = simpleDict.mapKeys { $0 }
        
        #expect(mapped == simpleDict)
    }
    
    @Test("compactMapKeys identity returns same values") func testCompactMapKeysIdentity() {
        
        let mapped = simpleDict.compactMapKeys { $0 }
        
        #expect(mapped == simpleDict)
    }
    
    
    //---------------
    // MARK: Helpers
    //---------------
    
    private let simpleDict = ["a": 1, "b": 2, "c": 3]
    private let intDict = [1: "one", 2: "two", 3: "three"]
}
