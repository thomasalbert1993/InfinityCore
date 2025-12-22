//
//  HasherFNV1a.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

/// A FNV-1a (Fowler–Noll–Vo) hash implementation.
///
/// Can be used instead of Swift's `Hasher` for generating cross-platform consistent hashes.
public struct HasherFNV1a {
    
    /// Combines a sequence of bytes into the current hash.
    ///
    /// - Parameter sequence: A sequence of `UInt8` to combine into the hash.
    mutating func combine<S: Sequence>(_ sequence: S) where S.Element == UInt8 {
        for byte in sequence {
            hashValue ^= UInt(byte)
            hashValue &*= prime
        }
    }
    
    /// The current hash value.
    var hash: UInt {
        hashValue
    }
    
    private var hashValue: UInt = 14_695_981_039_346_656_037
    private let prime: UInt = 1_099_511_628_211
}

extension HasherFNV1a {

    /// Combines a string into the FNV-1a hash.
    ///
    /// - Parameter string: The string to hash.
    public mutating func combine(_ string: String) {
        combine(string.utf8)
    }
    
    /// Combines a boolean into the FNV-1a hash.
    ///
    /// - Parameter bool: The boolean to hash.
    public mutating func combine(_ bool: Bool) {
        combine(CollectionOfOne(bool ? 1 : 0))
    }
}

extension FixedWidthInteger {
    
    /// Converts the integer into a `Data` instance.
    ///
    /// - Returns: A `Data` representation of the integer.
    public var data: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}
