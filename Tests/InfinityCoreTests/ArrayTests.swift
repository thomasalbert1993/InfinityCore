//
//  ArrayTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import InfinityCore

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
    
    
    //--------------------------------------------------
    // MARK: Array.randomElements(count:preserveOrder:)
    //--------------------------------------------------
    
    let array = Array(0..<20)
    
    @Test("Default count picks between 1 and collection count") func defaultCountRange() {
        
        for _ in 0..<100 {
            let result = array.randomElements()
            #expect(result.count >= 1)
            #expect(result.count <= array.count)
        }
    }
    
    @Test("Count range is respected") func countRangeIsRespected() {
        
        for _ in 0..<100 {
            let result = array.randomElements(count: 5...10)
            #expect(result.count >= 5)
            #expect(result.count <= 10)
        }
    }
    
    @Test("Returned elements are subset of original collection") func elementsAreFromSource() {
        
        for _ in 0..<100 {
            let result = array.randomElements()
            #expect(result.allSatisfy { array.contains($0) })
        }
    }
    
    @Test("Returned elements are unique") func noDuplicates() {
        
        for _ in 0..<100 {
            let result = array.randomElements()
            #expect(Set(result).count == result.count)
        }
    }
    
    @Test("PreserveOrder keeps relative ordering") func preserveOrderKeepsOrder() {
        
        for _ in 0..<100 {
            let result = array.randomElements(preserveOrder: true)

            let indexes = result.map { array.firstIndex(of: $0)! }
            #expect(indexes == indexes.sorted())
        }
    }
    
    @Test("Without preserveOrder order may differ") func shuffledOrderCanDiffer() {
        var orderChanged = false

        for _ in 0..<200 {
            let result = array.randomElements(count: 10...10, preserveOrder: false)
            let indexes = result.map { array.firstIndex(of: $0)! }
            if indexes != indexes.sorted() {
                orderChanged = true
                break
            }
        }

        #expect(orderChanged)
    }
    
    @Test("Full count returns all elements") func fullCountReturnsAllElements() {
        
        let result = array.randomElements(count: array.count...array.count)
        #expect(Set(result) == Set(array))
    }
    
    @Test("Single element range returns exactly one element") func singleElement() {
        
        for _ in 0..<100 {
            let result = array.randomElements(count: 1...1)
            #expect(result.count == 1)
            #expect(array.contains(result[0]))
        }
    }
    
    
    //---------------------------------
    // MARK: Array.removeFirst(while:)
    //---------------------------------
    
    @Test("removeFirst(while:) removes matching leading elements") func testRemoveFirstWhileRemovesLeading() {
        
        var array = [1, 2, 3, 4, 5]
        array.removeFirst(while: { $0 < 3 })
        
        #expect(array == [3, 4, 5])
    }
    
    @Test("removeFirst(while:) stops at first non-matching element") func testRemoveFirstWhileStopsAtFirstNonMatch() {
        
        var array = [2, 4, 1, 6, 8]
        array.removeFirst(while: { $0.isMultiple(of: 2) })
        
        #expect(array == [1, 6, 8])
    }
    
    @Test("removeFirst(while:) removes nothing when first element does not match") func testRemoveFirstWhileNoMatch() {
        
        var array = [5, 1, 2, 3]
        array.removeFirst(while: { $0 < 5 })
        
        #expect(array == [5, 1, 2, 3])
    }
    
    @Test("removeFirst(while:) removes all elements when all match") func testRemoveFirstWhileAllMatch() {
        
        var array = [1, 2, 3]
        array.removeFirst(while: { $0 < 10 })
        
        #expect(array.isEmpty)
    }
    
    @Test("removeFirst(while:) on empty array does nothing") func testRemoveFirstWhileEmpty() {
        
        var array: [Int] = []
        array.removeFirst(while: { _ in true })
        
        #expect(array.isEmpty)
    }
    
    @Test("removeFirst(while:) on single element matching") func testRemoveFirstWhileSingleMatch() {
        
        var array = [1]
        array.removeFirst(while: { $0 == 1 })
        
        #expect(array.isEmpty)
    }
    
    @Test("removeFirst(while:) on single element not matching") func testRemoveFirstWhileSingleNoMatch() {
        
        var array = [1]
        array.removeFirst(while: { $0 == 2 })
        
        #expect(array == [1])
    }
    
    
    //----------------------------
    // MARK: Array.chunked(into:)
    //----------------------------
    
    @Test("chunked(into:) splits array evenly") func testChunkedEvenSplit() {
        
        let array = [1, 2, 3, 4, 5, 6]
        let result = array.chunked(into: 2)
        
        #expect(result == [[1, 2], [3, 4], [5, 6]])
    }
    
    @Test("chunked(into:) last chunk contains remainder") func testChunkedRemainder() {
        
        let array = [1, 2, 3, 4, 5]
        let result = array.chunked(into: 2)
        
        #expect(result == [[1, 2], [3, 4], [5]])
    }
    
    @Test("chunked(into:) with size equal to count returns single chunk") func testChunkedSizeEqualsCount() {
        
        let array = [1, 2, 3]
        let result = array.chunked(into: 3)
        
        #expect(result == [[1, 2, 3]])
    }
    
    @Test("chunked(into:) with size greater than count returns single chunk") func testChunkedSizeGreaterThanCount() {
        
        let array = [1, 2]
        let result = array.chunked(into: 10)
        
        #expect(result == [[1, 2]])
    }
    
    @Test("chunked(into:) with size of 1 returns individual elements") func testChunkedSizeOne() {
        
        let array = ["a", "b", "c"]
        let result = array.chunked(into: 1)
        
        #expect(result == [["a"], ["b"], ["c"]])
    }
    
    @Test("chunked(into:) on empty array returns empty") func testChunkedEmpty() {
        
        let array: [Int] = []
        let result = array.chunked(into: 3)
        
        #expect(result.isEmpty)
    }
    
    @Test("chunked(into:) on single element array") func testChunkedSingleElement() {
        
        let array = [42]
        let result = array.chunked(into: 5)
        
        #expect(result == [[42]])
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
