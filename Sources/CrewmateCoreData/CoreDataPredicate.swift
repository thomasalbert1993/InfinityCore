//----------------------------------------------------
//  CoreDataPredicate.swift
//
//  Created by Thomas ALBERT on 11/08/2024.
//  All rights reserved.
//----------------------------------------------------

import Foundation

/// A typed wrapper around `NSPredicate` for providing custom predicates usable
/// within the scope of a given CoreData element.
///
public struct CoreDataPredicate<Element: CoreDataManageable> { // CoreDataFetchable
    
    /// The wrapped `NSPredicate`.
    public let predicate: NSPredicate
    
    /// Indicates wether soft deleted instances should be included within fetch requests
    /// when using this predicate.
    public let includeSoftDeleted: Bool
    
    public init(_ predicate: NSPredicate, includeSoftDeleted: Bool = false) {
        self.predicate = predicate
        self.includeSoftDeleted = includeSoftDeleted
    }
    
    public init(format: String, _ args: any CVarArg..., includeSoftDeleted: Bool = false) {
        predicate = .init(format: format, args)
        self.includeSoftDeleted = includeSoftDeleted
    }
    
    /// Evaluating the predicate for a given item.
    ///
    /// - Parameter item: The item to evaluate.
    ///
    /// - Returns: A boolean indicating wether the given item matches predicate.
    public func evaluate(with item: Element) -> Bool {
        predicate.evaluate(with: item)
    }
}

extension CoreDataPredicate {
    
    /// Wrapping a sub-predicate within a NOT predicate.
    public static func not(_ subPredicate: Self) -> Self {
        .init(NSCompoundPredicate(notPredicateWithSubpredicate: subPredicate.predicate))
    }
    
    /// Merging a set of sub-predicates with 'OR' operator.
    public static func or(_ subPredicates: [Self]) -> Self {
        .init(NSCompoundPredicate(orPredicateWithSubpredicates: subPredicates.map({ $0.predicate })))
    }
}

extension CoreDataPredicate where Element: CoreDataObject {
    
    /// Predicate for matching a given identifier (case sensitive).
    public static func id(_ id: String) -> Self {
        .init(format: "%K == %@", #keyPath(CoreDataObject.cd_id), id, includeSoftDeleted: true)
    }
    
    /// Predicate for matching a given set of identifiers (case sensitive).
    public static func ids(_ ids: [String]) -> Self {
        .init(format: "%K IN %@", #keyPath(CoreDataObject.cd_id), ids, includeSoftDeleted: true)
    }
}

extension CoreDataPredicate: CustomStringConvertible {
    
    public var description: String {
        "CoreDataPredicate<\(Element.self)>(\(predicate))"
    }
}
