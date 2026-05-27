//
//  Ranges.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 16/01/2026.
//

import Foundation
import Testing
@testable import InfinityCore

struct RangesTests {
    
    
    //---------------------------
    // MARK: ClosedRange<Double>
    //---------------------------
    
    @Test("nullableLowerBound returns nil for -Double.greatestFiniteMagnitude") func doubleNullableLowerBoundNil() {
        
        let range = ClosedRange<Double>(
            uncheckedBounds: (lower: -.greatestFiniteMagnitude, upper: 10)
        )
        
        #expect(range.nullableLowerBound == nil)
    }
    
    @Test("nullableUpperBound returns nil for Double.greatestFiniteMagnitude") func doubleNullableUpperBoundNil() {
        
        let range = ClosedRange<Double>(
            uncheckedBounds: (lower: 0, upper: .greatestFiniteMagnitude)
        )
        
        #expect(range.nullableUpperBound == nil)
    }
    
    @Test("nullable bounds return values when finite") func doubleNullableBoundsValues() {
        
        let range = 1.5...3.5
        
        #expect(range.nullableLowerBound == 1.5)
        #expect(range.nullableUpperBound == 3.5)
    }
    
    @Test("init with nil bounds creates unbounded range") func doubleInitWithNilBounds() {
        
        let range = ClosedRange<Double>(
            nullableLowerBound: nil,
            nullableUpperBound: nil
        )
        
        #expect(range.lowerBound == -.greatestFiniteMagnitude)
        #expect(range.upperBound == .greatestFiniteMagnitude)
    }
    
    @Test("init with partial nil bounds") func doubleInitWithPartialNilBounds() {
        
        let range = ClosedRange<Double>(
            nullableLowerBound: 5,
            nullableUpperBound: nil
        )
        
        #expect(range.lowerBound == 5)
        #expect(range.upperBound == .greatestFiniteMagnitude)
    }
    
    @Test("intersects returns true for overlapping ranges") func doubleIntersectsOverlapping() {
        
        let a = 1.0...5.0
        let b = 4.0...10.0
        
        #expect(a.intersects(with: b))
        #expect(b.intersects(with: a))
    }
    
    @Test("intersects returns true for touching ranges") func doubleIntersectsTouching() {
        
        let a = 1.0...5.0
        let b = 5.0...10.0
        
        #expect(a.intersects(with: b))
    }
    
    @Test("intersects returns false for disjoint ranges") func doubleIntersectsDisjoint() {
        
        let a = 1.0...3.0
        let b = 4.0...6.0
        
        #expect(!a.intersects(with: b))
    }
    
    
    //------------------------
    // MARK: ClosedRange<Int>
    //------------------------
    
    @Test("nullableLowerBound returns nil for Int.min") func intNullableLowerBoundNil() {
        
        let range = ClosedRange<Int>(
            uncheckedBounds: (lower: .min, upper: 10)
        )
        
        #expect(range.nullableLowerBound == nil)
    }
    
    @Test("nullableUpperBound returns nil for Int.max") func intNullableUpperBoundNil() {
        
        let range = ClosedRange<Int>(
            uncheckedBounds: (lower: 0, upper: .max)
        )
        
        #expect(range.nullableUpperBound == nil)
    }
    
    @Test("nullable bounds return values when finite") func intNullableBoundsValues() {
        
        let range = 10...20
        
        #expect(range.nullableLowerBound == 10)
        #expect(range.nullableUpperBound == 20)
    }
    
    @Test("init with nil bounds creates unbounded range") func intInitWithNilBounds() {
        
        let range = ClosedRange<Int>(
            nullableLowerBound: nil,
            nullableUpperBound: nil
        )
        
        #expect(range.lowerBound == .min)
        #expect(range.upperBound == .max)
    }
    
    @Test("init with partial nil bounds") func intInitWithPartialNilBounds() {
        
        let range = ClosedRange<Int>(
            nullableLowerBound: nil,
            nullableUpperBound: 100
        )
        
        #expect(range.lowerBound == .min)
        #expect(range.upperBound == 100)
    }
    
    @Test("intersects returns true for overlapping ranges") func intIntersectsOverlapping() {
        
        let a = 1...5
        let b = 3...10
        
        #expect(a.intersects(with: b))
        #expect(b.intersects(with: a))
    }
    
    @Test("intersects returns true for touching ranges") func intIntersectsTouching() {
        
        let a = 1...5
        let b = 5...8
        
        #expect(a.intersects(with: b))
    }
    
    @Test("intersects returns false for disjoint ranges") func intIntersectsDisjoint() {
        
        let a = 1...4
        let b = 5...9
        
        #expect(!a.intersects(with: b))
    }
}
