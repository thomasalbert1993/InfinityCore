//----------------------------------------------------
//  CoreDataManageable.swift
//
//  Created by Thomas ALBERT on 19/07/2023.
//  All rights reserved.
//----------------------------------------------------

import Foundation
import CoreData
import InfinityCore

public enum CoreDataSaveMode {
    case no
    case now
    case asSoonAsPossible
}

/// The `CoreDataManageable` protocol implements the base functions for fetching, creating
/// and deleting `CoreDataObject` instances.
///
public protocol CoreDataManageable: CoreDataObject {
    associatedtype CoreDataContext: CoreDataContextProtocol
}
extension CoreDataManageable {
    
    /// The CoreData context.
    public var coreDataContext: CoreDataContext {
        get throws {
            guard let context = managedObjectContext else {
                throw CoreDataError.contextIsNil(self)
            }
            return .init(context) // OR RETURN EXISTANT ONE???
        }
    }
    
    /// Asserting an object does not already exist with a given ID (in the scope of the calling class).
    ///
    /// - Parameter id: The identifier to match.
    public static func assertNotExist(withID id: String, in context: CoreDataContext) throws {
        if isThereAny(matching: [.id(id)], in: context) {
            throw CoreDataError.instanceAlreadyExists(type: Self.self, id: id)
        }
    }
    
    /// Clearing caches of all instances in a given context.
    ///
    /// - Parameter context: The CoreData context.
    public static func clearAllCaches(in context: CoreDataContext = .main) {
        for instance in fetch(in: context) {
            instance.clearCaches()
        }
    }
    
    /// The concrete subclasses.
    public static var concreteSubclasses: [Self.Type] {
        entity().managedObjectModel.entities.compactMap {
            $0.isAbstract ? nil : NSClassFromString($0.managedObjectClassName) as? Self.Type
        }
    }
    
    /// Generating a fetch request with a given set of predicates and limit.
    ///
    /// - Parameter predicates: The predicates to match.
    /// - Parameter sortDescriptors: Some sort descriptors for ordering results.
    /// - Parameter limit: The max number of results to fetch.
    ///
    /// - Returns: The corresponding fetch request.
    public static func makeFetchRequest(
        matching predicates: [CoreDataPredicate<Self>] = [],
        sortDescriptors: [CoreDataSortDescriptor<Self>] = [],
        limit: Int? = nil)
        -> NSFetchRequest<Self>
    {
        let request = NSFetchRequest<Self>(entityName: entityName)
        
        var nsPredicates = predicates.map { $0.predicate }
        
        if let softDeletable = self as? SoftDeletable.Type, !predicates.contains(where: { $0.includeSoftDeleted }) {
            nsPredicates.append(.init(format: "%K != %d", softDeletable.softDeletedAttributeName, true))
        }
        
        if nsPredicates.count > 1 {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: nsPredicates)
        } else {
            request.predicate = nsPredicates.first
        }
        
        if sortDescriptors.count > 0 {
            request.sortDescriptors = sortDescriptors.map( { $0.sortDescriptor })
        }
        if let limit {
            request.fetchLimit = limit
        }
        
        return request
    }
    
    
    //--------------------------
    // MARK: Fetching instances
    //--------------------------
    
    /// Performing a `NSFetchRequest` (thread-safe).
    ///
    /// - Parameter request: The fetch request.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The fetched instances.
    public static func fetch(request: NSFetchRequest<Self>, in context: CoreDataContext) -> [Self] {
        do {
            guard coreDataStack.isReady == true else {
                throw CoreDataError.contextIsNotReady(context.context)
            }
            return try context.performAndWait {
                try context.context.fetch(request)
            }
        }
        catch {
//            Log.error("Did fail to perform CoreData fetch request with error: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Getting the number of results of a given `NSFetchRequest` (thread-safe).
    ///
    /// - Parameter request: The fetch request.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The results count.
    public static func count(request: NSFetchRequest<Self>, in context: CoreDataContext) -> Int {
        do {
            guard coreDataStack.isReady == true else {
                throw CoreDataError.contextIsNotReady(context.context)
            }
            return try context.performAndWait {
                try context.context.count(for: request)
            }
        }
        catch {
//            Log.error("Did fail to perform CoreData count request with error: \(error.localizedDescription)")
            return 0
        }
    }
    
    /// Fetching the instances matching a given set of predicates (thread-safe).
    ///
    /// - Parameter predicates: The filtering predicates.
    /// - Parameter sortDescriptors: Some sort descriptors for ordering results.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The fetched instances.
    public static func fetch(
        matching predicates: [CoreDataPredicate<Self>] = [],
        sortedBy sortDescriptors: [CoreDataSortDescriptor<Self>] = [],
        in context: CoreDataContext = .main,
        limit: Int? = nil)
        -> [Self]
    {
        fetch(request: makeFetchRequest(matching: predicates, sortDescriptors: sortDescriptors, limit: limit), in: context)
    }
    
    /// Fetching the first instance matching a given set of predicates (thread-safe).
    ///
    /// - Parameter predicates: The filtering predicates.
    /// - Parameter sortDescriptors: Some sort descriptors for ordering results.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The fetched instances.
    public static func fetchFirst(
        matching predicates: [CoreDataPredicate<Self>] = [],
        sortedBy sortDescriptors: [CoreDataSortDescriptor<Self>] = [],
        in context: CoreDataContext = .main)
        -> Self?
    {
        fetch(matching: predicates, sortedBy: sortDescriptors, in: context, limit: 1).first
    }
    
    /// Fetching the first instance matching a given set of predicates, throwing when not found (thread-safe).
    ///
    /// - Parameter predicates: The filtering predicates.
    /// - Parameter sortDescriptors: Some sord descriptors for ordering results.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The first matching instance.
    public static func fetchFirstOrThrow(
        matching predicates: [CoreDataPredicate<Self>] = [],
        sortedBy sortDescriptors: [CoreDataSortDescriptor<Self>] = [],
        in context: CoreDataContext = .main)
        throws -> Self
    {
        try fetchFirst(matching: predicates, in: context) ?! CoreDataError.instanceNotFound(type: Self.self, predicates: predicates.map(\.description))
    }
    
    /// Getting the count of instances matching a given set of predicates (thread-safe).
    ///
    /// - Parameter predicates: The filtering predicates.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The instances count.
    public static func count(matching predicates: [CoreDataPredicate<Self>] = [], in context: CoreDataContext = .main) -> Int {
        count(request: makeFetchRequest(matching: predicates), in: context)
    }
    
    /// Checking if there is at least one instance matching a given set of predicates (thread-safe).
    ///
    /// - Parameter predicates: The filtering predicates.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: A boolean indicating if at least one instance has been found.
    ///
    /// - Note: Prefer using this function rather than `count(matching:in:)` as it's more optimized.
    public static func isThereAny(matching predicates: [CoreDataPredicate<Self>], in context: CoreDataContext = .main) -> Bool {
        count(request: makeFetchRequest(matching: predicates, limit: 1), in: context) > 0
    }
    
    /// Asserting there is no already existing object matching a given set of predicates.
    ///
    /// - Parameter predicates: The filtering predicates.
    /// - Parameter context: The CoreData context.
    public static func assertNotExists(matching predicates: [CoreDataPredicate<Self>], in context: CoreDataContext = .main) throws {
        guard !isThereAny(matching: predicates, in: context) else {
            throw CoreDataError.instanceAlreadyExists(type: Self.self, predicates: predicates.map(\.description))
        }
    }
    
    
    //-------------------------------------------
    // MARK: Fetching instances with identifiers
    //-------------------------------------------
    
    /// Fetching the first instance matching a given identifier (thread-safe).
    ///
    /// - Parameter id: The identifier to match (case insensitive).
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The matching instance.
    public static func fetch(id: String, in context: CoreDataContext = .main) -> Self? {
        fetch(matching: [ .id(id) ], in: context, limit: 1).first
    }
    
    /// Fetching the instances matching a given set of identifiers (thread-safe).
    ///
    /// - Parameter ids: The identifiers to match (case insensitive).
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The matching instances.
    ///
    /// - Note: We're assuming identifiers are globally unique so we limit the results
    /// count to the number of identifiers for optimization.
    public static func fetch(ids: [String], in context: CoreDataContext = .main) -> [Self] {
        fetch(matching: [ .ids(ids), ], in: context, limit: ids.count )
    }
    
    /// Fetching the first instance matching a given identifier, or throw if not exists (thread-safe).
    ///
    /// - Parameter id: The identifier to match (case insensitive).
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The matching instance.
    public static func fetchOrThrow(id: String, in context: CoreDataContext = .main) throws -> Self {
        try fetch(id: id, in: context) ?! CoreDataError.instanceNotFound(type: Self.self, id: id)
    }
    
    
    //--------------------------
    // MARK: Creating instances
    //--------------------------
    
    /// Creating a new instance with a given identifier (thread-safe).
    ///
    /// - Parameter id: The instance identifier.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The created instance.
    ///
    /// - Important: This function throws when an instance (of the calling class) already exists with the given identifier.
    @discardableResult
    public static func create(id: String? = nil, in context: CoreDataContext = .main, additionalSetup: ((Self) throws -> Void)? = nil) throws -> Self {
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context.context) else {
            throw CoreDataError.entityDoesNotExist(entityName)
        }
        guard !entity.isAbstract else {
            throw CoreDataError.entityMustNotBeAbstract(entityName)
        }
        guard coreDataStack.isReady == true else {
            throw CoreDataError.contextIsNotReady(context.context)
        }
        
        let id = id ?? uniqueID()
        
        try assertNotExist(withID: id, in: context) // 3% performance loss
        
        return try context.performAndWait {
            let instance = Self(entity: entity, insertInto: context.context)
            instance.assignID(id)
            instance.didCreate() // FIXME: Often crashes here
            try additionalSetup?(instance)
            return instance
        }
    }
    
    
    //--------------------------
    // MARK: Deleting instances
    //--------------------------
    
    /// Deleting all instances (thread-safe).
    ///
    /// - Parameter context: The CoreData context.
    public static func deleteAll(in context: CoreDataContext = .main) throws {
        guard coreDataStack.isReady == true else {
            throw CoreDataError.contextIsNotReady(context.context)
        }
        _ = try context.performAndWait {
            try context.context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName)))
        }
    }
    
    /// Deleting all instances matching a given predicate (thread-safe).
    ///
    /// - Parameter predicates: The filtering predicates.
    /// - Parameter context: The CoreData context.
    public static func delete(matching predicates: [CoreDataPredicate<Self>], in context: CoreDataContext = .main) throws {
        guard coreDataStack.isReady == true else {
            throw CoreDataError.contextIsNotReady(context.context)
        }
        try context.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates.map { $0.predicate })
            try context.context.execute(NSBatchDeleteRequest(fetchRequest: request))
        }
    }
    
    
    //---------------------
    // MARK: Thread-safety
    //---------------------
    
    /// Performing safely an action.
    ///
    /// - Parameter save: The saving mode to perform after operation (`no`, `now` or `asSoonAsPossible`).
    /// - Parameter closure: The closure to perform.
    ///
    /// - Returns: The closure result.
    @discardableResult
    public func performSafely<T>(save: CoreDataSaveMode = .no, _ closure: () throws -> T) throws -> T {
        let context = try coreDataContext
        return try context.performAndWait {
            let result = try closure()
            switch save {
                case .no:
                    break
                case .now:
                    try context.save()
                case .asSoonAsPossible:
                    context.saveAsSoonAsPossible()
            }
            return result
        }
    }
    
    /// Saving the CoreData context (thread-safe).
    public func saveSafely() throws {
        try coreDataContext.saveSafely()
    }
    
    /// Saving the CoreData context as soon as possible (thread-safe).
    ///
    /// - Important: Do not use this function when saving critical updates.
    public func saveAsSoonAsPossible() throws {
        try coreDataContext.saveAsSoonAsPossible()
    }
    
    /// Getting an instance from its object ID in a given context.
    ///
    /// - Parameter objectID: The object ID to fetch.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The corresponding instance, when exists.
    public static func instance(with objectID: NSManagedObjectID, in context: CoreDataContext = .main) -> Self? {
        try? context.context.existingObject(with: objectID) as? Self
    }
    
    /// Getting some instances from their object ID in a given context.
    ///
    /// - Parameter objectsISs: The objects IDs to fetch.
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The corresponding instances, when exist.
    public static func instances(with objectsIDs: [NSManagedObjectID], in context: CoreDataContext = .main) -> [Self] {
        objectsIDs.compactMap {
            instance(with: $0, in: context)
        }
    }
}
