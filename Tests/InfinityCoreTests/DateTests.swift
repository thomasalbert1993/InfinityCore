//
//  DateTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 05/02/2026.
//

import Foundation
import Testing
@testable import InfinityCore

struct DateTests {
    
    @Test("slightlyBefore is strictly earlier than original") func slightlyBeforeIsStrictlyEarlierThanOriginal() {
        
        let date = Date()
        
        let before = date.slightlyBefore
        
        #expect(before < date)
        #expect(before != date)
    }
    
    @Test("slightlyAfter is strictly later than original") func slightlyAfterIsStrictlyLaterThanOriginal() {
        
        let date = Date()
        
        let after = date.slightlyAfter
        
        #expect(after > date)
        #expect(after != date)
    }
    
    @Test("slightlyBefore and slightlyAfter preserver ordering") func slightlyBeforeAndSlightlyAfterPreserveOrdering() {
        
        let date = Date()
        
        let before = date.slightlyBefore
        let after = date.slightlyAfter
        
        #expect(before < date)
        #expect(date < after)
        #expect(before < after)
    }
    
    @Test("Chaining slightlyBefore and slightlyAfter round trips correctly") func chainingSlightlyBeforeAndSlightlyAfterRoundTripsCorrectly() {
        
        let date = Date()
        
        let roundTrip = date
            .slightlyAfter
            .slightlyBefore
        
        #expect(roundTrip <= date)
    }
    
    @Test("Offsets are small enough to not affect seconds") func offsetsAreSmallEnoughToNotAffectSeconds() {
        
        let date = Date()
        
        let before = date.slightlyBefore
        let after = date.slightlyAfter
        
        #expect(abs(date.timeIntervalSince(before)) < 1e-6)
        #expect(abs(after.timeIntervalSince(date)) < 1e-6)
    }
}
