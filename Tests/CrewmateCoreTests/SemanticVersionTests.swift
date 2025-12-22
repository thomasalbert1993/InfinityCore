//
//  SemanticVersionTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct SemanticVersionTests {
    
    @Test("Test init from full literal string") func testInitFromLiteralFull() {
        
        let version = SemanticVersion("1.2.3")
        
        #expect(version != nil)
        #expect(version?.major == 1)
        #expect(version?.minor == 2)
        #expect(version?.patch == 3)
    }

    @Test("Test init from major only") func testInitFromLiteralMajorOnly() {
            
        let version = SemanticVersion("2")
        
        #expect(version?.major == 2)
        #expect(version?.minor == 0)
        #expect(version?.patch == 0)
    }

    @Test("Test init from major and minor") func testInitFromLiteralMajorMinor() {
            
        let version = SemanticVersion("3.4")
        
        #expect(version?.major == 3)
        #expect(version?.minor == 4)
        #expect(version?.patch == 0)
    }
    
    @Test("Test too many components fails") func testTooManyComponents() {
        
        let version = SemanticVersion("1.2.3.4")
        
        #expect(version == nil)
    }
    
    @Test("Test non-numeric components are ignored causing failure") func testNonNumericLiteral() {
        
        let version = SemanticVersion("1.a.3")
        
        #expect(version == nil)
    }
    
    @Test("Test empty string fails") func testEmptyString() {
        
        let version = SemanticVersion("")

        #expect(version == nil)
    }
    
    @Test("Test literal and description match") func testLiteralAndDescription() {
        
        let version = SemanticVersion(major: 5, minor: 6, patch: 7)
        
        #expect(version.literal == "5.6.7")
        #expect(version.description == "5.6.7")
    }
    
    @Test("Test comparison by major version") func testComparisonMajor() {
        #expect(
            SemanticVersion(major: 1, minor: 0, patch: 0)
            < SemanticVersion(major: 2, minor: 0, patch: 0)
        )
    }

    @Test("Test comparison by minor version") func testComparisonMinor() {
        #expect(
            SemanticVersion(major: 1, minor: 1, patch: 0)
            < SemanticVersion(major: 1, minor: 2, patch: 0)
        )
    }

    @Test("Test comparison by patch version") func testComparisonPatch() {
        #expect(
            SemanticVersion(major: 1, minor: 2, patch: 3)
            < SemanticVersion(major: 1, minor: 2, patch: 4)
        )
    }

    @Test("Test equal versions are not less than each other") func testComparisonEquality() {
        
        let a = SemanticVersion(major: 1, minor: 2, patch: 3)
        let b = SemanticVersion(major: 1, minor: 2, patch: 3)

        #expect(!(a < b))
        #expect(!(b < a))
    }
    
    @Test("Test sorting versions") func testSorting() {
        
        let versions = [
            SemanticVersion(major: 2, minor: 0, patch: 0),
            SemanticVersion(major: 1, minor: 10, patch: 0),
            SemanticVersion(major: 1, minor: 2, patch: 3),
            SemanticVersion(major: 1, minor: 2, patch: 0)
        ]
        
        let sorted = versions.sorted()
        
        #expect(sorted.map(\.literal) == [
            "1.2.0",
            "1.2.3",
            "1.10.0",
            "2.0.0",
        ])
    }
    
    @Test("Test equal versions have same hash") func testHashEquality() {
        
        let a = SemanticVersion(major: 1, minor: 2, patch: 3)
        let b = SemanticVersion(major: 1, minor: 2, patch: 3)
        
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }
    
    @Test("Test set uniqueness works") func testSetUniqueness() {
        
        let versions: Set<SemanticVersion> = [
            SemanticVersion(major: 1, minor: 0, patch: 0),
            SemanticVersion(major: 1, minor: 0, patch: 0)
        ]
        
        #expect(versions.count == 1)
    }
}
