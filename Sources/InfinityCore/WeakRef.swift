//
//  WeakRef.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 27/05/2026.
//

import Foundation

/// A wrapper for storing a weak reference to an object.
///
/// When this object is deallocated, the wrapped `value` becomes `nil`.
/// You can use this wrapper to store weak references in arrays, dictionaries...
///
/// - Note: You are still responsible for cleaning-up the cleared `WeakRef` instances.
public final class WeakRef<T: AnyObject> {
    
    /// The wrapped weak value.
    public weak var value: T?
    
    /// Created a `WeakRef` with a given value.
    ///
    /// - Parameter value: The wrapped value.
    public init(_ value: T) {
        self.value = value
    }
}
