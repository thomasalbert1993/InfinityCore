//
//  SemanticVersion.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

/// Represents a semantic version number following the `major.minor.patch` convention.
///
/// `SemanticVersion` allows easy comparison of versions and provides a literal string
/// representation. It conforms to `Comparable` and `CustomStringConvertible`.
public struct SemanticVersion: Hashable, Comparable, Sendable, CustomStringConvertible, LosslessStringConvertible {
    
    /// The major version number.
    public var major: Int
    
    /// The minor version number.
    public var minor: Int
    
    /// The patch version number.
    public var patch: Int
    
    /// The literal string representation of the semantic version.
    ///
    /// Example: `"1.2.3"`
    public var literal: String {
        "\(major).\(minor).\(patch)"
    }
    
    
    //--------------------
    // MARK: Initializers
    //--------------------
    
    /// Creates a `SemanticVersion` from individual `major`, `minor`, and `patch` numbers.
    ///
    /// - Parameter major: The major version number.
    /// - Parameter minor: The minor version number.
    /// - Parameter patch: The patch version number.
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    /// Initializes a `SemanticVersion` from a literal string (e.g., `"1.2.48"`).
    ///
    /// - Parameter literal: A string representing the version, with up to 3 components.
    ///
    /// - Returns: A `SemanticVersion` if parsing succeeds, otherwise `nil`.
    public init?(_ literal: String) {
        
        let components = literal.split(separator: ".")
        guard components.count > 0,
              components.count <= 3,
              components.allSatisfy({ $0.allSatisfy({ ("0"..."9").contains($0) }) }) else {
            return nil
        }
        
        major = Int(components[0])!
        minor = components.count > 1 ? Int(components[1])! : 0
        patch = components.count > 2 ? Int(components[2])! : 0
    }
    
    
    //---------------------------------
    // MARK: <CustomStringConvertible>
    //---------------------------------
    
    public var description: String {
        literal
    }
    
    
    //--------------------
    // MARK: <Comparable>
    //--------------------
    
    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }
}
