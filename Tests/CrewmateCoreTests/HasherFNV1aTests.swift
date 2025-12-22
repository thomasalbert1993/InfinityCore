//
//  HasherFNV1aTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct HasherFNV1aTests {
    
    @Test("Test hash consistency") func testHashConsistency() {
        
        var hasher = HasherFNV1a()
        hasher.combine("Hello World!")
        hasher.combine("Crewmate is magic.")
        hasher.combine("7ED75A76-6568-4B58-B40D-7DE1ECEF18BE")
        
        #expect(hasher.hash == 12_555_672_910_653_025_573)
    }
    
    @Test("Test same input produces same hash") func testSameInputProducesSameHash() {
        
        var h1 = HasherFNV1a()
        var h2 = HasherFNV1a()

        let input = "Deterministic input"

        h1.combine(input)
        h2.combine(input)

        #expect(h1.hash == h2.hash)
    }
    
    @Test("Test order of combination matters") func testOrderOfCombinationMatters() {
        
        var h1 = HasherFNV1a()
        var h2 = HasherFNV1a()

        h1.combine("Hello")
        h1.combine("World")

        h2.combine("World")
        h2.combine("Hello")

        #expect(h1.hash != h2.hash)
    }
    
    @Test("Test empty hasher returns offset basis") func testEmptyHasherReturnsOffsetBasis() {
        
        let hasher = HasherFNV1a()
        #expect(hasher.hash == 14_695_981_039_346_656_037)
    }
    
    @Test("Test boolean hashing") func testBooleanHashing() {
        
        var hTrue = HasherFNV1a()
        var hFalse = HasherFNV1a()

        hTrue.combine(true)
        hFalse.combine(false)

        #expect(hTrue.hash != hFalse.hash)
    }
    
    @Test("Test string hash matches UTF8 bytes") func testStringHashMatchesUTF8Bytes() {
        
        let string = "Hello World"

        var h1 = HasherFNV1a()
        var h2 = HasherFNV1a()

        h1.combine(string)
        h2.combine(string.utf8)

        #expect(h1.hash == h2.hash)
    }
}
