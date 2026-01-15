//----------------------------------------------------
//  CoreDataObject.swift
//
//  Created by Thomas ALBERT on 30/03/2023.
//  All rights reserved.
//----------------------------------------------------

import CoreData
import Foundation
import CrewmateCore

public typealias CoreDataObjectID = NSManagedObjectID

public enum CoreDataError: DebuggableError {
    
    case entityDoesNotExist(String)
    case entityMustNotBeAbstract(String)
    
    case contextIsNotReady(NSManagedObjectContext)
    case contextIsNil(CoreDataObject)
    case mustBeInMainContext(CoreDataObject)
    
    case instanceNotFound(type: CoreDataObject.Type, predicates: [String]) // predicates are given as String as this is a generic struct
    case instanceAlreadyExists(type: CoreDataObject.Type, predicates: [String]) // predicates are given as String as this is a generic struct
    case instanceNotFound(type: CoreDataObject.Type, id: String)
    case instanceAlreadyExists(type: CoreDataObject.Type, id: String)
}

/// The base class for all CoreData objects.
///
/// - Important: All CoreData properties must have `cd_` prefix.
///
open class CoreDataObject: NSManagedObject, Identifiable {
    
    /// The corresponding CoreData entity name.
    public static var entityName: String {
        .init(describing: self)
    }
    
    /// The corresponding CoreData stack.
    public static var coreDataStack: CoreDataStack {
        .stack(for: self)
    }
    
    /// The corresponding CoreData stack.
    public var coreDataStack: CoreDataStack {
        .stack(for: self)
    }
    
    /// Asserting object is in main CoreData context.
    public func assertIsInMainContext() throws {
        guard isInMainContext else {
            throw CoreDataError.mustBeInMainContext(self)
        }
    }
    
    
    //-----------
    // MARK: IDs
    //-----------
    
    /// Generating an unique ID (with corresponding `idPrefix` when exists).
    public static func uniqueID() -> String {
        .uniqueID(withPrefix: idPrefix)
    }
    
    /// The ID prefix for this object type.
    /// Override this var to provide a custom prefix (like `usr_` for example).
    open class var idPrefix: String {
        ""
    }
    
    
    // MARK: - Functions to override
    
    /// Function called when the object has been created.
    open func didCreate() {
    }
    
    
    //------------------------
    // MARK: Transient Caches
    //------------------------
    
    /// Clearing caches.
    ///
    /// Override this function to clear any temporary (ie. non-persisted) cache
    /// to free up memory.
    open func clearCaches() {
    }
    
    
    //-------------------
    // MARK: Initializer
    //-------------------
    
    required public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    //-----------------------
    // MARK: NSManagedObject
    //-----------------------
    
    override open func didTurnIntoFault() {
        super.didTurnIntoFault()
        
        clearCaches()
    }
    
    
    //----------------
    // MARK: NSObject
    //----------------
    
    override open var description: String {
        DebugDescription(for: self).description
    }
    
    
    //----------------------
    // MARK: <Identifiable>
    //----------------------
    
    /// The unique identifier (thread-safe).
    public var id: String {
        if let id = _id {
            return id
        }
        guard let id = managedObjectContext?.performAndWait({ cd_id }) else {
//            Log.warning("Did fail to get ID for CoreData object with nil context")
            return ""
        }
        _id = id
        return id
    }
    
    /// Assigning the instance identifier.
    ///
    /// - Parameter id: The (new) identifier for this instance.
    ///
    /// - Important: You must always use this function instead of setting `cd_id` directly as it also set the cached transient property.
    public func assignID(_ id: String) {
        cd_id = id
        _id = id
    }
    
    
    //---------------------------
    // MARK: CoreData properties
    //---------------------------
    
    @NSManaged internal var cd_id: String
    
    
    //---------------
    // MARK: Private
    //---------------
    
    private var _id: String?
}

extension CoreDataManageable {
    
    /// Getting the corresponding instance in another CoreData context.
    ///
    /// - Parameter context: The CoreData context you want to get the corresponding instance.
    ///
    /// - Returns: The corresponding instance in given context.
    public func instance(in context: CoreDataContext) -> Self? {
        
        guard context.context != managedObjectContext else {
            return self
        }
        
        return try? context.context.existingObject(with: objectID) as? Self
    }
}

extension Array where Element: CoreDataManageable {
    
    /// Getting the corresponding instances in another CoreData context.
    ///
    /// - Parameter context: The CoreData context you want to get the corresponding instances.
    ///
    /// - Returns: The corresponding instances in given context.
    public func instances(in context: Element.CoreDataContext) -> [Element] {
        compactMap { $0.instance(in: context) }
    }
}


extension CoreDataObject {
    
    /// Indicates if the instance belongs to the main CoreData context
    public var isInMainContext: Bool {
        managedObjectContext == coreDataStack.mainContext
    }
}


/// A thread-safe reference to a `CoreDataObject`, wrapping its `id` and its type.
///
public struct CoreDataReference<T: CoreDataManageable>: Identifiable, Hashable, Sendable {
    public let id: String
}
extension CoreDataReference {
    public init(_ instance: T) {
        self.init(id: instance.id)
    }
    public func instance(in context: T.CoreDataContext = .main) -> T? {
        T.fetch(id: id, in: context)
    }
}
extension Array {
    public func instances<T: CoreDataObject>(in context: T.CoreDataContext = .main) -> [T] where Element == CoreDataReference<T> {
        compactMap { $0.instance(in: context) }
    }
}
extension CoreDataManageable {
    public var coreDataReference: CoreDataReference<Self> {
        .init(self)
    }
}

/// A thread-safe untyped reference to a `CoreDataObject`, wrapping its `id` and its type.
///
public struct UntypedCoreDataReference: Identifiable, Hashable, Sendable {
    public let id: String
    public let objectType: any CoreDataManageable.Type
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension UntypedCoreDataReference {
    public init<T: CoreDataManageable>(_ instance: T) {
        self.init(id: instance.id, objectType: type(of: instance))
    }
}

public protocol SoftDeletable: CoreDataObject {
    
    static var softDeletedAttributeName: String { get }
}
extension SoftDeletable {
    
    /// Indicates wether the instance is soft deleted.
    public var isSoftDeleted: Bool {
        value(forKey: Self.softDeletedAttributeName) as? Bool ?? false
    }
    
    /// An helper that returns `nil` when instance is soft deleted.
    public var softDeletedAsNil: Self? {
        isSoftDeleted ? nil : self
    }
}
extension Array where Element: SoftDeletable {
    
    /// Removing the soft deleted instances.
    public var removingSoftDeleted: Self {
        filter { !$0.isSoftDeleted }
    }
}
