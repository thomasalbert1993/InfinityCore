//----------------------------------------------------
//  String.swift
//
//  Created by Thomas ALBERT on 20/12/2025.
//  All rights reserved.
//----------------------------------------------------

import Foundation

extension String {
    
    /// Converts an UTC ISO8601 formatted date into a `Date`.
    /// Both second and microsecond precision are allowed.
    public func toDate() throws -> Date {
        try ISO8601DateFormatter.date(from: self)
    }
}
