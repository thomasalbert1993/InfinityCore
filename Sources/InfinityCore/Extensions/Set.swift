//
//  Set.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 23/12/2025.
//

import Foundation

extension Set {
    
    /// Returns the elements that were added to and removed from the receiver compared to a previous snapshot.
    ///
    /// This method compares `self` (the current set) to `previousValue` (an earlier set) and produces
    /// two sets:
    /// - `added`: elements that are present in `self` but not in `previousValue`.
    /// - `removed`: elements that are present in `previousValue` but not in `self`.
    ///
    /// - Parameter previousValue: The earlier set to compare against.
    ///
    /// - Returns: A tuple `(added:removed:)` containing the elements that were added and removed.
    ///
    /// - Note: This is different from `symmetricDifference(_:)`, which returns a single set of all
    /// elements that differ between the two sets without telling you whether each element was added
    /// or removed.
    public func difference(from previousValue: Self) -> (added: Self, removed: Self) {
        
        var added = Self()
        var removed = Self()
        
        for item in self where !previousValue.contains(item) {
            added.insert(item)
        }
        for item in previousValue where !self.contains(item) {
            removed.insert(item)
        }
        
        return (added, removed)
    }
}
