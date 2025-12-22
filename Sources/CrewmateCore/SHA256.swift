//
//  Crypto.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import CryptoKit

extension Data {
    
    /// Computes the SHA-256 hash of the data.
    ///
    /// - Returns: A hexadecimal string representing the SHA-256 hash.
    public func sha256() -> String {
        SHA256.hash(data: self)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}

extension String {
    
    /// Computes the SHA-256 hash of the string.
    ///
    /// The string is first converted to UTF-8 data, then hashed.
    ///
    /// - Returns: A hexadecimal string representing the SHA-256 hash.
    public func sha256() -> String {
        data(using: .utf8)!.sha256()
    }
}
