//----------------------------------------------------
//  CoreDataSortDescriptor.swift
//
//  Created by Thomas ALBERT on 11/08/2024.
//  All rights reserved.
//----------------------------------------------------

import Foundation

/// A typed wrapped arount `NSSortDescriptor` for providing custom store descriptors usable
/// within the scope of a given CoreData element.
///
public struct CoreDataSortDescriptor<Element: CoreDataManageable> {
    
    public enum SortDirection {
        case ascending
        case descending
    }
    
    public let sortDescriptor: NSSortDescriptor
    
    public init(_ sortDescriptor: NSSortDescriptor) {
        self.sortDescriptor = sortDescriptor
    }
    
    public init(key: String, direction: SortDirection) {
        sortDescriptor = .init(key: key, ascending: direction == .ascending)
    }
}
