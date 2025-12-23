//----------------------------------------------------
//  String.swift
//
//  Created by Thomas ALBERT on 20/12/2025.
//  All rights reserved.
//----------------------------------------------------

import Foundation

extension String {
    
    /// Trims whitespaces from string.
    public func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Removes accents from string.
    public func removingAccents() -> String {
        folding(options: .diacriticInsensitive, locale: .current)
    }
    
    /// Converts an UTC ISO8601 formatted date into a `Date`.
    /// Both second and microsecond precision are allowed.
    public func toDate() throws -> Date {
        try ISO8601DateFormatter.date(from: self)
    }
    
    /// Converts string to an `URL`.
    public func toURL() throws -> URL {
        try URL(string: trimmed()) ?! "Invalid URL: \(self)"
    }
}
