//
//  Keyable.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

/// A protocol representing an object identifiable by a unique `key`.
///
/// `Keyable` requires a `key` property that can be used to uniquely identify the object.
///
/// This protocol provides default implementations for `Equatable` and `Hashable` based on the `key`.
public protocol Keyable<Key>: Hashable {
    
    /// The type of key used to identify the object.
    associatedtype Key: Hashable
    
    /// The key value used to uniquely identify this object.
    var key: Key { get }
}

extension Keyable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key == rhs.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

extension Collection where Element: Keyable {
    
    /// Returns the first element in the collection with the specified key.
    ///
    /// - Parameter key: The key to search for.
    ///
    /// - Returns: The first element whose `key` matches the given key, or `nil` if not found.
    public func first(withKey key: Element.Key) -> Element? {
        first { $0.key == key }
    }
    
    /// Checks whether collection contains an element with a given key.
    ///
    /// - Parameter key; The key to search for.
    ///
    /// - Returns: `true` if the collection contains an element with that key.
    public func contains(key: Element.Key) -> Bool {
        first(withKey: key) != nil
    }
}
