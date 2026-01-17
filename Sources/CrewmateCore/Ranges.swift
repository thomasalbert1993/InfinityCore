//
//  Ranges.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 16/01/2026.
//

import Foundation

public protocol RangeBound: Comparable, Sendable {
    static var minApplicableValue: Self { get }
    static var maxApplicableValue: Self { get }
}

extension Int: RangeBound {
    public static var minApplicableValue: Int { .min }
    public static var maxApplicableValue: Int { .max }
}

extension UInt: RangeBound {
    public static var minApplicableValue: UInt { .min }
    public static var maxApplicableValue: UInt { .max }
}

extension Double: RangeBound {
    public static var minApplicableValue: Double { -.greatestFiniteMagnitude }
    public static var maxApplicableValue: Double { .greatestFiniteMagnitude }
}

extension Float: RangeBound {
    public static var minApplicableValue: Float { -.greatestFiniteMagnitude }
    public static var maxApplicableValue: Float { .greatestFiniteMagnitude }
}

extension Date: RangeBound {
    public static var minApplicableValue: Date { .distantPast }
    public static var maxApplicableValue: Date { .distantFuture }
}

extension ClosedRange where Bound: RangeBound {
    
    /// The nullable lower bound (`nil` when equals to min appliable value).
    public var nullableLowerBound: Bound? {
        lowerBound != Bound.minApplicableValue ? lowerBound : nil
    }
    
    /// The nullable upper bound (`nil` when equals to max appliable value).
    public var nullableUpperBound: Bound? {
        upperBound != Bound.maxApplicableValue ? upperBound : nil
    }
    
    /// Initializing from nullable lower and upper bounds.
    ///
    /// - Parameter nullableLowerBound: The lower bound.
    /// - Parameter nullableUpperBound: The upper bound.
    public init(nullableLowerBound: Bound?, nullableUpperBound: Bound?) {
        self.init(uncheckedBounds: (
            lower: nullableLowerBound ?? Bound.minApplicableValue,
            upper: nullableUpperBound ?? Bound.maxApplicableValue
        ))
    }
}

extension ClosedRange {
    
    /// Checking wether two ranges are intersecting.
    ///
    /// - Parameter other: The range to compare.
    ///
    /// - Returns: A boolean indicating wether the two ranges are intersecting.
    public func intersects(with other: Self) -> Bool {
        lowerBound <= other.upperBound && upperBound >= other.lowerBound
    }
}
