//----------------------------------------------------
//  Double.swift
//
//  Created by Thomas ALBERT on 20/12/2025.
//  All rights reserved.
//----------------------------------------------------

import Foundation

extension Double {
    
    /// Rounds a `Double` to a given number of decimals.
    ///
    /// - Parameter decimals: The number of decimals to keep.
    ///
    /// - Returns: The rounded value.
    public func rounded(toDecimals decimals: Int) -> Double {
        let divisor = pow(10, Double(decimals))
        return (self * divisor).rounded() / divisor
    }
    
    /// Indicates whether a `Double` has a fractional part of not.
    public var hasFractionalPart: Bool {
        truncatingRemainder(dividingBy: 1) != 0
    }
}
