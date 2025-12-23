//
//  SetTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 23/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct SetTests {
    
    
    //-----------------------
    // MARK: Sets Difference
    //-----------------------
    
    @Test("Test difference detects added and removed elements") func testAddedAndRemoved() {
        
        let previous: Set = [1, 2, 3]
        let current: Set = [2, 3, 4, 5]
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added == [4, 5])
        #expect(diff.removed == [1])
    }
    
    @Test("Test difference with identical sets returns empty added and removed") func testNoDifference() {
        
        let previous: Set = ["a", "b", "c"]
        let current: Set = ["a", "b", "c"]
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added.isEmpty)
        #expect(diff.removed.isEmpty)
    }
    
    @Test("Test difference with only added elements") func testOnlyAdded() {
        
        let previous: Set = [1, 2]
        let current: Set = [1, 2, 3, 4]
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added == [3, 4])
        #expect(diff.removed.isEmpty)
    }
    
    @Test("Test difference with only removed elements") func testOnlyRemoved() {
        
        let previous: Set = [1, 2, 3]
        let current: Set = [1]
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added.isEmpty)
        #expect(diff.removed == [2, 3])
    }
    
    @Test("Test difference from empty previous set") func testPreviousEmpty() {
        
        let previous: Set<Int> = []
        let current: Set = [1, 2]
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added == [1, 2])
        #expect(diff.removed.isEmpty)
    }
    
    @Test("Test difference to empty current set") func testCurrentEmpty() {
        
        let previous: Set = [1, 2]
        let current: Set<Int> = []
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added.isEmpty)
        #expect(diff.removed == [1, 2])
    }
    
    @Test("Test difference between two empty sets") func testBothEmpty() {
        
        let previous: Set<Int> = []
        let current: Set<Int> = []
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added.isEmpty)
        #expect(diff.removed.isEmpty)
    }
    
    @Test("difference works with custom Hashable types") func testCustomHashable() {
        
        struct User: Hashable {
            let id: Int
        }
        
        let previous: Set = [User(id: 1), User(id: 2)]
        let current: Set = [User(id: 2), User(id: 3)]
        
        let diff = current.difference(from: previous)
        
        #expect(diff.added == [User(id: 3)])
        #expect(diff.removed == [User(id: 1)])
    }
    
    @Test("Test difference partitions symmetricDifference") func testRelationToSymmetricDifference() {
        
        let previous: Set = [1, 2, 3]
        let current: Set = [2, 3, 4]
        
        let diff = current.difference(from: previous)
        
        let symmetric = current.symmetricDifference(previous)
        
        #expect(diff.added.union(diff.removed) == symmetric)
        #expect(diff.added.isDisjoint(with: diff.removed))
    }
}
