//
//  Collection.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

extension Collection {
    
    /// Returns `nil` when collection is empty.
    public var emptyAsNil: Self? {
        isEmpty ? nil : self
    }
}
