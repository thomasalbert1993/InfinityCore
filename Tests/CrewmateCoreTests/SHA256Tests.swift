//
//  SHA256Tests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct SHA256Tests {
    
    @Test("Test SHA-256 of empty data") func testEmptyDataSHA256() {
        let data = Data()
        
        let hash = data.sha256()
        
        #expect(hash == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    }
    
    @Test("Test SHA-256 of 'abc'") func testABCDataSHA256() {
        let data = Data("abc".utf8)
        
        let hash = data.sha256()
        
        #expect(hash == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }
    
    @Test("Test string SHA-256 matches Data SHA-256") func testStringAndDataConsistency() {
        let string = "Crewmate is magic 🪄"
        
        let dataHash = Data(string.utf8).sha256()
        let stringHash = string.sha256()
        
        #expect(dataHash == stringHash)
    }
    
    @Test("Test UTF-8 encoding is used for String hashing") func testUTF8Encoding() {
        
        let string = "é" // multi-byte in UTF-8
        let hash = string.sha256()
        
        #expect(hash == Data(string.utf8).sha256())
    }
    
    @Test("Test SHA-256 is deterministic") func testDeterminism() {
        
        let data = Data("deterministic".utf8)
        
        let hash1 = data.sha256()
        let hash2 = data.sha256()
        
        #expect(hash1 == hash2)
    }
    
    @Test("Test different input produces different hash") func testDifferentInputDifferentHash() {
        
        let hash1 = Data("hello".utf8).sha256()
        let hash2 = Data("hellO".utf8).sha256()
        
        #expect(hash1 != hash2)
    }
    
    @Test("Test SHA-256 output is lowercase hex and correct length") func testOutputFormat() {
        
        let hash = Data("test".utf8).sha256()
        
        #expect(hash.count == 64)
        #expect(hash.allSatisfy { $0.isNumber || ("a"..."f").contains($0) })
    }
    
    @Test("Test SHA-256 works for large data") func testLargeData() {
        
        let data = Data(repeating: 0xAB, count: 1_000_000)
        
        let hash = data.sha256()
        
        #expect(hash.count == 64)
    }
}
