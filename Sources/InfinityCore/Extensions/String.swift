//
//  String.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 20/12/2025.
//

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
    
    
    //---------------------------------
    // MARK: Generating Random Strings
    //---------------------------------
    
    /// Generating an unique identifier (based on a lowercased UUIDv4) with a given prefix.
    ///
    /// - Parameter prefix: The identifier prefix (will be followed by '_' separator).
    ///
    /// - Returns: The generated identifier.
    public static func uniqueID(withPrefix prefix: String? = nil) -> String {
        if let prefix, !prefix.isEmpty {
            return (prefix + "_" + UUID().uuidString).lowercased()
        }
        return UUID().uuidString.lowercased()
    }
    
    /// Generating a random string composed of uppercased characters and digits.
    ///
    /// - Parameter length: The length you want.
    ///
    /// - Returns: The generated string.
    public static func randomUppercasedCharactersAndDigits(length: Int) -> String {
        let characters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789").map { String($0) }
        var output = String()
        for _ in 0..<length {
            output += characters.randomElement()!
        }
        return output
    }
}
