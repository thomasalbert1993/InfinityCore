//
//  Array.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

extension Array {
    
    public subscript (indexSet: IndexSet) -> [Element] {
        indexSet.map { self[$0] }
    }
    
    /// Returns some random elements of the collection.
    ///
    /// - Parameter count: The range of elements to pick.
    /// - Parameter preserveOrder: Indicates whether picked elements should be returned
    /// by preserving their ordering in the collection.
    ///
    /// - Returns: The picked random elements.
    public func randomElements(count: ClosedRange<Int>? = nil, preserveOrder: Bool = false) -> Self {
        
        let count = Int.random(in: count ?? 1...self.count)
        
        var pickedIndexes = IndexSet()
        var allIndexes = IndexSet(integersIn: 0..<self.count)
        
        for _ in 0..<count {
            let index = allIndexes.randomElement()!
            allIndexes.remove(index)
            pickedIndexes.insert(index)
        }
        
        let items = self[pickedIndexes]
        return preserveOrder ? items : items.shuffled()
    }
    
    /// Removes elements from the beginning of the array while the predicate returns `true`.
    ///
    /// - Parameter predicate: The predicate to evaluate for each element.
    public mutating func removeFirst(while predicate: (Element) throws -> Bool) rethrows {
        while try !isEmpty && predicate(first!) {
            removeFirst()
        }
    }
    
    /// Splits the array into chunks of the given size.
    ///
    /// - Parameter size: The expected chunk size.
    ///
    /// - Returns: The splitted chunks.
    public func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
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
