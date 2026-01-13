//
//  SequenceTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 13/01/2026.
//

import Foundation
import Testing
@testable import CrewmateCore

struct SequenceTests {
    
    
    //-----------------------------
    // MARK: Sequence.grouped(by:)
    //-----------------------------
    
    @Test("Groups elements by a simple key path") func testGroupsElementsBySimpleKeyPath() {
        
        let people = [
            Person(name: "Alice", age: 30, city: "Paris"),
            Person(name: "Bob", age: 25, city: "Paris"),
            Person(name: "Charlie", age: 30, city: "London")
        ]

        let result = people.grouped(by: \.age)

        #expect(result.count == 2)
        #expect(result[30] == [
            Person(name: "Alice", age: 30, city: "Paris"),
            Person(name: "Charlie", age: 30, city: "London")
        ])
        #expect(result[25] == [
            Person(name: "Bob", age: 25, city: "Paris")
        ])
    }

    @Test("Groups elements by a string key") func testGroupsElementsByStringKey() {
        
        let people = [
            Person(name: "Alice", age: 30, city: "Paris"),
            Person(name: "Bob", age: 25, city: "Paris"),
            Person(name: "Charlie", age: 30, city: "London")
        ]

        let result = people.grouped(by: \.city)

        #expect(result.keys.sorted() == ["London", "Paris"])
        #expect(result["Paris"]?.count == 2)
        #expect(result["London"]?.count == 1)
    }

    @Test("Preserves original order within each group") func testPreservesOriginalOrderWithinEachGroup() {
        
        let people = [
            Person(name: "A", age: 1, city: "X"),
            Person(name: "B", age: 1, city: "X"),
            Person(name: "C", age: 1, city: "X")
        ]

        let result = people.grouped(by: \.city)

        #expect(result["X"] == people)
    }

    @Test("Returns empty dictionary for empty array") func testReturnsEmptyDictionaryForEmptyArray() {
        
        let people = [Person]()

        let result = people.grouped(by: \.age)

        #expect(result.isEmpty)
    }
    
    
    //---------------
    // MARK: Helpers
    //---------------
    
    private struct Person: Equatable {
        let name: String
        let age: Int
        let city: String
    }
}
