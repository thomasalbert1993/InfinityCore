//
//  Array.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

extension Array {
    
    public subscript (indexSet: IndexSet) -> [Element] {
        indexSet.map { self[$0] }
    }
}

extension Array where Element: Equatable {
    
    /// Removes an element.
    ///
    /// - Parameter element: The element to remove.
    public mutating func remove(_ element: Element) {
        removeAll { $0 == element }
    }
    
    /// Removes some elements.
    ///
    /// - Parameter elements: The elements to remove.
    public mutating func remove(_ elements: any Collection<Element>) {
        removeAll { elements.contains($0) }
    }
}

extension Array where Element: Hashable {
    
    /// Gets the distinct values, keeping ordering.
    ///
    /// - Returns: The distinct values.
    public func distinctValues() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
    
    /// Gets the distinct valuse based on a given key, keeping ordering.
    ///
    /// - Parameter key: The uniqueness key for filtering.
    ///
    /// - Returns: The distinct values based on that key.
    public func distinctValues<Key: Hashable>(by key: (Element) -> Key) -> [Element] {
        var seen = Set<Key>()
        return filter { seen.insert(key($0)).inserted }
    }
    
    /// Gets the distinct valuse based on a given key, keeping ordering.
    ///
    /// - Parameter key: The uniqueness keypath for filtering.
    ///
    /// - Returns: The distinct values based on that keypath.
    public func distinctValues<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Element] {
        distinctValues(by: { $0[keyPath: keyPath] })
    }
}
