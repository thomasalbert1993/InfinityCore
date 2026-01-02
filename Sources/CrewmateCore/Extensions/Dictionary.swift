//
//  Dictionary.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

extension Dictionary {
    
    /// Maps keys using a given transform.
    ///
    /// - Parameter transform: The transform to apply to keys.
    ///
    /// - Returns: The mapped dictionary.
    public func mapKeys<T>(_ transform: (Key) throws -> T) rethrows -> [T:Value] {
        var dict = [T:Value]()
        for (key, value) in self {
            let newKey = try transform(key)
            dict[newKey] = value
        }
        return dict
    }
    
    /// Maps keys using a given transform. Keys are omitted when transform returns `nil`.
    ///
    /// - Parameter transform: The transform to apply to keys.
    ///
    /// - Returns: The mapped dictionary.
    public func compactMapKeys<T>(_ transform: (Key) throws -> T?) rethrows -> [T:Value] {
        var dict = [T:Value]()
        for (key, value) in self {
            if let newKey = try transform(key) {
                dict[newKey] = value
            }
        }
        return dict
    }
    
    /// Checks whether the dictionary contains a given key.
    ///
    /// - Parameter key: The key to match.
    ///
    /// - Returns: A boolean indicating whether the key exists.
    public func contains(key: Key) -> Bool {
        contains { $0.key == key }
    }
}
