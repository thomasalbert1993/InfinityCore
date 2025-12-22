//
//  DataTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct DataTests {
    
    @Test("Test empty data produces empty string") func testEmptyData() {
        
        #expect(TestData.emptyData.hexString == "")
    }
        
    @Test("Test simple data converts correctly") func testSimpleData() {
        
        #expect(TestData.simpleData.hexString == "00010aff")
    }
        
    @Test("Test deterministic conversion") func testDeterministic() {
        
        let hex1 = TestData.simpleData.hexString
        let hex2 = TestData.simpleData.hexString
            
        #expect(hex1 == hex2)
    }
    
    @Test("Hex string uses lowercase letters") func testLowercaseHex() {
        
        let hex = Data([0xAB, 0xCD, 0xEF]).hexString
        
        #expect(hex == "abcdef")
    }
    
    @Test("Large data conversion produces correct length") func testLargeDataLength() {
        
        let hex = TestData.largeData.hexString
        
        #expect(hex.count == 1000 * 2) // 2 chars per byte
    }
        
    @Test("Large data conversion is deterministic") func testLargeDataDeterminism() {
        
        let hex1 = TestData.largeData.hexString
        let hex2 = TestData.largeData.hexString
        
        #expect(hex1 == hex2)
    }
    
    @Test("All byte values produce correct hex") func testAllByteValues() {
        
        let allBytes = Data((0...255).map { UInt8($0) })
        let hex = allBytes.hexString
        
        #expect(hex.prefix(2) == "00")
        #expect(hex.suffix(2) == "ff")
        #expect(hex.count == 256 * 2)
    }
    
    
    //---------------
    // MARK: Helpers
    //---------------
    
    private enum TestData {
        static let emptyData = Data()
        static let simpleData = Data([0x00, 0x01, 0x0A, 0xFF])
        static let largeData = Data(repeating: 0xAB, count: 1000)
    }
}
