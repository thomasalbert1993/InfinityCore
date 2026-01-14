//
//  NumbersTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 13/01/2026.
//

import Foundation
import Testing
@testable import CrewmateCore

struct NumbersTests {
    
    
    //-----------------------------------
    // MARK: Double.rounded(toDecimals:)
    //-----------------------------------

    @Test("Rounds to given number of decimals") func testRoundsToGivenNumberOfDecimals() {
        
        #expect(1.2345.rounded(toDecimals: 2) == 1.23)
        #expect(1.235.rounded(toDecimals: 2) == 1.24)
        #expect(1.0.rounded(toDecimals: 2) == 1.0)
    }

    @Test("Rounds with zero decimals") func testRoundsWithZeroDecimals() {
        
        #expect(1.4.rounded(toDecimals: 0) == 1.0)
        #expect(1.5.rounded(toDecimals: 0) == 2.0)
        #expect(-1.5.rounded(toDecimals: 0) == -2.0)
    }

    @Test("Rounds negative numbers correctly") func testRoundsNegativeNumbersCorrectly() {
        
        #expect((-1.234).rounded(toDecimals: 2) == -1.23)
        #expect((-1.235).rounded(toDecimals: 2) == -1.24)
    }

    //--------------------------------
    // MARK: Double.hasFractionalPart
    //--------------------------------

    @Test("Detects fractional part correctly") func testDetectsFractionalPartCorrectly() {
        
        #expect(1.1.hasFractionalPart == true)
        #expect(1.0.hasFractionalPart == false)
        #expect(0.0001.hasFractionalPart == true)
    }

    @Test("Works with negative numbers") func testWorksWithNegativeNumbers() {
        
        #expect((-1.5).hasFractionalPart == true)
        #expect((-2.0).hasFractionalPart == false)
    }

    @Test("Zero has no fractional part") func testZeroHasNoFractionalPart() {
        
        #expect(0.0.hasFractionalPart == false)
    }
    
    
    //----------------------
    // MARK: Sequence.sum()
    //----------------------

    @Test("Sums integers correctly") func testSumsIntegersCorrectly() {
        
        let values = [1, 2, 3, 4, 5]
        #expect(values.sum() == 15)
    }

    @Test("Sums doubles correctly") func testSumsDoublesCorrectly() {
        
        let values = [1.5, 2.5, 3.0]
        #expect(values.sum() == 7.0)
    }

    @Test("Returns zero for empty sequence") func testReturnsZeroForEmptySequence() {
        
        let values: [Int] = []
        #expect(values.sum() == 0)
    }

    @Test("Works with negative values") func testWorksWithNegativeValues() {
        
        let values = [-1, 2, -3, 4]
        #expect(values.sum() == 2)
    }
    
    
    //-----------------------
    // MAKR: NSNumber.isBool
    //-----------------------
    
    @Test("isBool returns true only for real booleans") func isBoolReturnsTrueOnlyForRealBooleans() {
        
        
        let value1: NSNumber = false
        let value2: NSNumber = true
        let value3: NSNumber = 0
        let value4: NSNumber = 1
        let value5: NSNumber = 3.14
        
        #expect(value1.isBool == true)
        #expect(value2.isBool == true)
        #expect(value3.isBool == false)
        #expect(value4.isBool == false)
        #expect(value5.isBool == false)
    }
}
