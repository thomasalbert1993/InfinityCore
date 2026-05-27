//
//  Base62.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 08/01/2026.
//

import Foundation
import BigInt

extension Data {
    
    /// Encodes the `Data` instance as a Base62 string.
    ///
    /// Base62 uses the characters `0-9`, `A-Z`, and `a-z`.
    ///
    /// - Returns: A Base62 encoded string representing the data.
    public func base62EncodedString() -> String {
        let base62Alphabet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        var base62String = ""
        var value = BigUInt(self)
        while value > 0 {
            let remainder = Int(value % 62)
            base62String = String(base62Alphabet[remainder]) + base62String
            value /= 62
        }
        return base62String
    }
}

extension String {
    
    /// Gets the Base62 encoded representation of the string.
    ///
    /// The string is first converted to UTF-8 data.
    public func base62Encoded() -> String {
        data(using: .utf8)!.base62EncodedString()
    }
}

extension UUID {
    
    /// Gets the Base62 encoded string representation of the UUID.
    public func base62Encoded() -> String {
        uuidString.base62Encoded()
    }
}
