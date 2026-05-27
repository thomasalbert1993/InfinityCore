//
//  Identifiable.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

extension Collection where Element: Identifiable {
    
    /// The elements identifiers.
    public var ids: [Element.ID] {
        map { $0.id }
    }
    
    /// Gets the first element matching a given identifier.
    ///
    /// - Parameter id: The identifier to fetch.
    ///
    /// - Returns: The first element with this identifier.
    public func first(id: Element.ID) -> Element? {
        first { $0.id == id }
    }
    
    /// Gets the index of the first element matching a given identifier.
    ///
    /// - Parameter id: The identifier to match.
    ///
    /// - Returns: The index of the first element with this identifier.
    public func firstIndex(id: Element.ID) -> Index? {
        firstIndex { $0.id == id }
    }
    
    /// Checs whether collection contains an element with a given identifier.
    ///
    /// - Parameter id: The identifier to match.
    ///
    /// - Returns: A boolean indicating whether there is at least one element with this identifier.
    public func contains(id: Element.ID) -> Bool {
        contains { $0.id == id }
    }
}

extension Array where Element: Identifiable {
    
    /// Removes all elements matching a given identifier.
    ///
    /// - Parameter id: The identifier to match.
    public mutating func remove(id: Element.ID) {
        removeAll { $0.id == id }
    }
}

extension Set where Element: Identifiable {
    
    /// Remove any element matching a given identifier.
    ///
    /// - Parameter id: The identifier to match.
    public mutating func remove(id: Element.ID) {
        
        while let index = firstIndex(where: { $0.id == id }) {
            remove(at: index)
        }
    }
}
