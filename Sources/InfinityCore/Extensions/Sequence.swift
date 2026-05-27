//
//  Sequence.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 13/01/2026.
//

import Foundation

extension Sequence {
    
    /// Groups elements using a given keypath.
    ///
    /// - Parameter keyPath: The keypath for grouping.
    ///
    /// - Returns: The grouped elements.
    public func grouped<Key: Hashable>(by keyPath: KeyPath<Element,Key>) -> [Key:[Element]] {
        .init(grouping: self) {
            $0[keyPath: keyPath]
        }
    }
}
