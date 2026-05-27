//
//  IdentifiableTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import InfinityCore

struct IdentifiableTests {
    
    @Test("Test ids property returns all identifiers") func testIDs() {
        
        let ids = testItems.ids
        #expect(ids == [1, 2, 3, 2])
    }
    
    @Test("first(id:) returns first matching element") func testFirstWithID() {
        
        let item = testItems.first(id: 2)
        #expect(item == TestItem(id: 2, name: "Bob"))
        
        let missing = testItems.first(id: 99)
        #expect(missing == nil)
    }
    
    @Test("firstIndex(id:) returns correct index") func testFirstIndexWithID() {
        
        let index = testItems.firstIndex(id: 2)
        #expect(index == 1)
        
        let missingIndex = testItems.firstIndex(id: 99)
        #expect(missingIndex == nil)
    }
    
    @Test("contains(id:) works correctly") func testContainsID() {
        
        #expect(testItems.contains(id: 2) == true)
        #expect(testItems.contains(id: 99) == false)
    }
    
    @Test("remove(id:) removes all matching elements") func testRemoveAllWithID() {
        
        var mutableUsers = testItems
        mutableUsers.remove(id: 2)
        
        #expect(mutableUsers == [
            TestItem(id: 1, name: "Alice"),
            TestItem(id: 3, name: "Charlie")
        ])
    }
    
    @Test("remove(id:) does nothing if no match") func testRemoveAllWithIDNoMatch() {
        
        var mutableUsers = testItems
        mutableUsers.remove(id: 99)
        
        #expect(mutableUsers == testItems)
    }
    
    
    //---------------
    // MARK: Helpers
    //---------------
    
    private struct TestItem: Identifiable, Equatable {
        let id: Int
        let name: String
    }
    
    private let testItems = [
        TestItem(id: 1, name: "Alice"),
        TestItem(id: 2, name: "Bob"),
        TestItem(id: 3, name: "Charlie"),
        TestItem(id: 2, name: "David") // duplicate ID for testing
    ]
}
