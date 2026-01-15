//----------------------------------------------------
//  CoreDataContext.swift
//
//  Created by Thomas ALBERT on 10/10/2025.
//  All rights reserved.
//----------------------------------------------------

import Foundation
import CoreData

/// A protocol for defining typed CoreData contexts wrappers binded to a `CoreDataStack`.
///
/// You should always use typed contexts instead of `NSManagedObjectContext` to avoid sharing
/// contexts between objects of different stacks/models.
///
public protocol CoreDataContextProtocol: AnyObject {
    
    /// The related `CoreDataStack`.
    static var stack: CoreDataStack { get }
    
    /// The shared main context.
    static var main: Self { get }
    
    /// The underlying `NSManagedObjectContext`.
    var context: NSManagedObjectContext { get }
    
    /// Creates an instance with a given context.
    ///
    /// - Parameter context: The underlying `NSManagedObjectContext` or `nil` for main context.
    ///
    /// - Important: As the persistent container can be regenerated when `CoreDataStock` reload stores,
    /// you should never pass the `context` parameter when referring to the main context but
    /// only for background (specific) contexts. This way, accessing `main` shared context will always
    /// return the current valid main context from corresponding `stack`.
    init(_ context: NSManagedObjectContext?)
}

extension CoreDataContextProtocol {
    
    //----------------------
    // Convenient Accessors
    //----------------------
    
    public func perform(_ block: @escaping () -> ()) {
        context.perform(block)
    }
    public func performAndWait<T>(_ block: () -> T) -> T {
        context.performAndWait(block)
    }
    public func performAndWait<T>(_ block: () throws -> T) rethrows -> T {
        try context.performAndWait(block)
    }
    public func save() throws {
        try context.save()
    }
    public func saveSafely() throws {
        try performAndWait {
            if context.hasChanges {
                try save()
            }
        }
    }
    public func saveAsSoonAsPossible() {
        context.saveAsSoonAsPossible() // TO REWRITE HERE INSTEAD
    }
    
    public func delete<T: CoreDataManageable>(_ object: T) where T.CoreDataContext == Self {
        context.delete(object)
    }
    
    public static func performInBackground(_ task: @escaping (Self) -> Void) {
        let context = Self(stack.newBackgroundContext())
        context.perform {
            task(context)
        }
    }
    
    public static func enqueueBackgroundTask(_ task: @escaping (Self) -> Void) {
        stack.enqueueBackgroundTask { nsContext in
            task(Self(nsContext))
        }
    }
    public static func enqueueBackgroundTask(_ task: @escaping (Self) throws -> Void) async throws {
        try await stack.enqueueBackgroundTask { nsContext in
            try task(Self(nsContext))
        }
    }
    public static func enqueueBackgroundTask<T>(_ task: @escaping (Self) throws -> T) async throws -> T {
        try await stack.enqueueBackgroundTask { nsContext in
            try task(Self(nsContext))
        }
    }
}
