//
//  ArrayTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct ArrayTests {
    
    
    //------------------------
    // MARK: Array[indexSet:]
    //------------------------
    
    @Test("Test elements are returned in IndexSet order") func testElementsAreReturnedInIndexSetOrder() {
        
        let array = ["a", "b", "c", "d", "e"]
        let indexSet = IndexSet([0, 2, 4])

        let result = array[indexSet]

        #expect(result == ["a", "c", "e"])
    }

    @Test("Test ascending order is preserved even if IndexSet is created unordered") func testAscendingOrderIsPreservedEvenIfIndexSetIsCreatedUnordered() {
        
        let array = [10, 20, 30, 40, 50]
        var indexSet = IndexSet()
        indexSet.insert(3)
        indexSet.insert(1)

        let result = array[indexSet]

        #expect(result == [20, 40])
    }

    @Test("Test empty array is returned for empty IndexSet") func testEmptyArrayIsReturnedForEmptyIndexSet() {
        
        let array = ["x", "y", "z"]
        let indexSet = IndexSet()

        let result = array[indexSet]

        #expect(result.isEmpty)
    }

    @Test("Test with single index") func testWithSingleIndex() {
        
        let array = ["apple", "banana", "cherry"]
        let indexSet = IndexSet(integer: 1)

        let result = array[indexSet]

        #expect(result == ["banana"])
    }
    
    
    //------------------------
    // MARK: Array.remove(_:)
    //------------------------
    
    @Test("Test remove single element") func testRemoveSingle() {
        
        let numbers = [1, 2, 3, 2, 4]
        let letters = ["a", "b", "c", "b", "d"]
        
        var nums = numbers
        nums.remove(2)
        
        #expect(nums == [1, 3, 4]) // all 2's removed
        
        var chars = letters
        chars.remove("b")
        
        #expect(chars == ["a", "c", "d"]) // all "b"s removed
    }

    @Test("Test remove single element not present does nothing") func testRemoveSingleNotPresent() {
        
        let numbers = [1, 2, 3, 2, 4]
        let letters = ["a", "b", "c", "b", "d"]
        
        var nums = numbers
        nums.remove(99)

        #expect(nums == numbers)

        var chars = letters
        chars.remove("z")

        #expect(chars == letters)
    }
    
    @Test("Test remove multiple elements") func testRemoveMultiple() {
        
        let numbers = [1, 2, 3, 2, 4]
        let letters = ["a", "b", "c", "b", "d"]
        
        var nums = numbers
        nums.remove([2, 3])
        
        #expect(nums == [1, 4])

        var chars = letters
        chars.remove(["b", "d"])

        #expect(chars == ["a", "c"])
    }

    @Test("Test remove multiple elements partially present") func testRemoveMultiplePartial() {
           
        let numbers = [1, 2, 3, 2, 4]
        let letters = ["a", "b", "c", "b", "d"]
        
        var nums = numbers
        nums.remove([2, 99])
        
        #expect(nums == [1, 3, 4]) // only 2 removed
        
        var chars = letters
        chars.remove(["b", "z"])
        
        #expect(chars == ["a", "c", "d"]) // only "b" removed
    }

    @Test("Test remove multiple elements none present does nothing") func testRemoveMultipleNone() {
        
        let numbers = [1, 2, 3, 2, 4]
        let letters = ["a", "b", "c", "b", "d"]
        
        var nums = numbers
        nums.remove([99, 100])
        
        #expect(nums == numbers)
        
        var chars = letters
        chars.remove(["x", "y"])
        
        #expect(chars == letters)
    }
    
    @Test("Test remove single element on empty array") func testRemoveSingleEmpty() {
        
        var empty: [Int] = []
        empty.remove(1)
        
        #expect(empty.isEmpty)
    }

    @Test("Test remove multiple elements on empty array") func testRemoveMultipleEmpty() {
        
        var empty: [String] = []
        empty.remove(["a", "b"])
        
        #expect(empty.isEmpty)
    }
    
    @Test("Test remove handles duplicates correctly") func testRemoveDuplicates() {
        
        var nums = [1, 2, 2, 3, 2, 4]
        nums.remove(2)
        
        #expect(nums == [1, 3, 4])
    }
    
    @Test("Test remove multiple elements handles duplicates correctly") func testRemoveMultipleDuplicates() {
        
        var nums = [1, 2, 2, 3, 2, 4]
        nums.remove([2, 3])
        
        #expect(nums == [1, 4])
    }
    
    
    //------------------------------
    // MARK: Array.distinctValues()
    //------------------------------
    
    @Test("Test distinctValues removes duplicates and preserves order") func testDistinctValuesRemovesDuplicates() {
        
        let numbers = [1, 2, 3, 2, 4, 1]
        
        let result = numbers.distinctValues()

        #expect(result == [1, 2, 3, 4])
    }

    @Test("Test distinctValues works with strings") func testDistinctValuesStrings() {
        
        let letters = ["a", "b", "a", "c", "b"]
        
        let result = letters.distinctValues()
        
        #expect(result == ["a", "b", "c"])
    }
    
    @Test("Test distinctValues on empty array returns empty array") func testDistinctValuesEmpty() {
        
        let empty: [Int] = []

        #expect(empty.distinctValues().isEmpty)
    }

    @Test("Test distinctValues on array with no duplicates") func testDistinctValuesNoDuplicates() {
        
        let array = [1, 2, 3, 4]

        let result = array.distinctValues()

        #expect(result == array)
    }
    
    @Test("Test distinctValues on single element array") func testDistinctValuesSingleElement() {
        
        let array = [42]
        
        let result = array.distinctValues()
        
        #expect(result == [42])
    }
    
    @Test("Test distinctValues is deterministic in content") func testDistinctValuesDeterminism() {
        
        let numbers = [1, 2, 3, 2, 4, 1]
        
        let r1 = numbers.distinctValues()
        let r2 = numbers.distinctValues()

        #expect(r1 == r2)
    }
    
    
    //---------------------------------
    // MARK: Array.distinctValues(by:)
    //---------------------------------
    
    @Test("distinctValues(by:) is deterministic") func testDistinctValuesByKeyDeterministic() {
        
        struct User: Hashable {
            let id: Int
            let name: String
        }
        
        let users = [
            User(id: 1, name: "A"),
            User(id: 2, name: "B"),
            User(id: 1, name: "C")
        ]
        
        let r1 = users.distinctValues(by: { $0.id })
        let r2 = users.distinctValues(by: { $0.id })
        
        #expect(r1.map(\.id) == r2.map(\.id))
    }

    @Test("Test distinctValues works with custom Hashable types") func testDistinctValuesCustomType() {
     
        struct User: Hashable {
            let id: Int
            let name: String
        }
        
        let users = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob"),
            User(id: 1, name: "Alice"), // <-- duplicate
        ]
        
        let result = users.distinctValues()
        
        #expect(result.map(\.id) == [1, 2])
        #expect(result.map(\.name) == ["Alice", "Bob"])
    }
    
    @Test("distinctValues(by:) removes duplicates based on key and preserves order") func testDistinctValuesByKey() {
        
        struct User: Hashable {
            let id: Int
            let name: String
        }
        
        let users = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob"),
            User(id: 1, name: "Alice Clone"),
            User(id: 3, name: "Charlie"),
            User(id: 2, name: "Bob Clone")
        ]
        
        let result = users.distinctValues(by: { $0.id })
        
        #expect(result.map(\.id) == [1, 2, 3])
        #expect(result.map(\.name) == ["Alice", "Bob", "Charlie"])
    }
}
