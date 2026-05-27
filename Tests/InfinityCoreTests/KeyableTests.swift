//
//  KeyableTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import InfinityCore

struct KeyableTests {
    
    @Test("Test instances with same key are equal") func testInstancesWithSameKeyAreEqual() {
        
        let a = TestItem(key: 1, value: "A")
        let b = TestItem(key: 1, value: "B")
        
        #expect(a == b)
    }
    
    @Test("Test instances with different keys are not equal") func testInstancesWithDifferentKeysAreNotEqual() {
        
        let a = TestItem(key: 1, value: "A")
        let b = TestItem(key: 2, value: "A")
        
        #expect(a != b)
    }
    
    @Test("Test instances with same key have same hash") func testHashSameKey() {
        
        let a = TestItem(key: 42, value: "First")
        let b = TestItem(key: 42, value: "Second")
        
        #expect(a.hashValue == b.hashValue)
    }

    @Test("Test instances with different keys have different hashes") func testHashDifferentKey() {
        
        let a = TestItem(key: 1, value: "A")
        let b = TestItem(key: 2, value: "A")
        
        #expect(a.hashValue != b.hashValue)
    }
    
    @Test("Test set contains only one element per key") func testSetUniquenessByKey() {
        
        let a = TestItem(key: 1, value: "A")
        let b = TestItem(key: 1, value: "B")
        
        let set: Set<TestItem> = [a, b]
        
        #expect(set.count == 1)
    }
    
    @Test("Test first(withKey:) returns matching element") func testFirstWithKeyReturnsMatchingElement() {
        
        let items = [
            TestItem(key: 1, value: "A"),
            TestItem(key: 2, value: "B"),
            TestItem(key: 3, value: "C")
        ]
        
        let result = items.first(withKey: 2)
        
        #expect(result?.value == "B")
    }

    @Test("Test first(withKey:) returns nil when not found") func testFirstWithKeyRturnsNilWhenNotFound() {
        
        let items = [
            TestItem(key: 1, value: "A"),
            TestItem(key: 2, value: "B")
        ]
        
        let result = items.first(withKey: 99)
        
        #expect(result == nil)
    }
    
    @Test("Test contains(key:) returns true when key exists") func testContainsKeyReturnsTrueWhenKeyExists() {
        
        let items = [
            TestItem(key: 1, value: "A"),
            TestItem(key: 2, value: "B")
        ]
        
        #expect(items.contains(key: 2))
    }

    @Test("Test contains(key:) returns false when key does not exist") func testContainsKeyReturnsFalseWhenKeyDoesNotExist() {
        
        let items = [
            TestItem(key: 1, value: "A"),
            TestItem(key: 2, value: "B")
        ]
        
        #expect(!items.contains(key: 99))
    }
    
    @Test("Test first(withKey:) returns first matching element in order") func testFirstWithKeyReturnsFirstMatchingElementInOrder() {
        
        let items = [
            TestItem(key: 1, value: "First"),
            TestItem(key: 1, value: "Second")
        ]
        
        let result = items.first(withKey: 1)
        
        #expect(result?.value == "First")
    }
    
    
    //---------------
    // MARK: Private
    //---------------
    
    private struct TestItem: Keyable {
        let key: Int
        let value: String
    }
}
