//
//  IdentifiableTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct IdentifiableTests {
    
    @Test("Test ids property returns all identifiers") func testIDs() {
        
        let ids = testItems.ids
        #expect(ids == [1, 2, 3, 2])
    }
    
    @Test("Test first(withID:) returns first matching element") func testFirstWithID() {
        
        let item = testItems.first(withID: 2)
        #expect(item == TestItem(id: 2, name: "Bob"))
        
        let missing = testItems.first(withID: 99)
        #expect(missing == nil)
    }
    
    @Test("Test firstIndex(withID:) returns correct index") func testFirstIndexWithID() {
        
        let index = testItems.firstIndex(withID: 2)
        #expect(index == 1)
        
        let missingIndex = testItems.firstIndex(withID: 99)
        #expect(missingIndex == nil)
    }
    
    @Test("Test containsID(_:) works correctly") func testContainsID() {
        
        #expect(testItems.containsID(2) == true)
        #expect(testItems.containsID(99) == false)
    }
    
    @Test("Test removeAll(withID:) removes all matching elements") func testRemoveAllWithID() {
        
        var mutableUsers = testItems
        mutableUsers.removeAll(withID: 2)
        
        #expect(mutableUsers == [
            TestItem(id: 1, name: "Alice"),
            TestItem(id: 3, name: "Charlie")
        ])
    }
    
    @Test("Test removeAll(withID:) does nothing if no match") func testRemoveAllWithIDNoMatch() {
        
        var mutableUsers = testItems
        mutableUsers.removeAll(withID: 99)
        
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
