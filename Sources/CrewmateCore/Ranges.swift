//
//  Ranges.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 16/01/2026.
//

import Foundation

extension ClosedRange<Double> {
    
    /// The nullable lower bound (`nil` when equals to min appliable value).
    public var nullableLowerBound: Double? {
        lowerBound != -.greatestFiniteMagnitude ? lowerBound : nil
    }
    
    /// The nullable upper bound (`nil` when equals to max appliable value).
    public var nullableUpperBound: Double? {
        upperBound != .greatestFiniteMagnitude ? upperBound : nil
    }
    
    /// Checking wether two ranges are intersecting.
    ///
    /// - Parameter other: The range to compare.
    ///
    /// - Returns: A boolean indicating wether the two ranges are intersecting.
    public func intersects(with other: Self) -> Bool {
        lowerBound <= other.upperBound && upperBound >= other.lowerBound
    }
    
    /// Initializing from nullable lower and upper bounds.
    ///
    /// - Parameter nullableLowerBound: The lower bound.
    /// - Parameter nullableUpperBound: The upper bound.
    public init(nullableLowerBound: Double?, nullableUpperBound: Double?) {
        self.init(uncheckedBounds: (
            lower: nullableLowerBound ?? -.greatestFiniteMagnitude,
            upper: nullableUpperBound ?? .greatestFiniteMagnitude
        ))
    }
}

extension ClosedRange<Int> {
    
    /// The nullable lower bound (`nil` when equals to min appliable value).
    public var nullableLowerBound: Int? {
        lowerBound != .min ? lowerBound : nil
    }
    
    /// The nullable upper bound (`nil` when equals to max appliable value).
    public var nullableUpperBound: Int? {
        upperBound != .max ? upperBound : nil
    }
    
    /// Checking wether two ranges are intersecting.
    ///
    /// - Parameter other: The range to compare.
    ///
    /// - Returns: A boolean indicating wether the two ranges are intersecting.
    public func intersects(with other: Self) -> Bool {
        lowerBound <= other.upperBound && upperBound >= other.lowerBound
    }
    
    /// Initializing from nullable lower and upper bounds.
    ///
    /// - Parameter nullableLowerBound: The lower bound.
    /// - Parameter nullableUpperBound: The upper bound.
    public init(nullableLowerBound: Int?, nullableUpperBound: Int?) {
        self.init(uncheckedBounds: (
            lower: nullableLowerBound ?? .min,
            upper: nullableUpperBound ?? .max
        ))
    }
}
