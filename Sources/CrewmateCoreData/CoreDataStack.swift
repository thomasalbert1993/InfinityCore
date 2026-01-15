//----------------------------------------------------
//  CoreDataStack.swift
//
//  Created by Thomas ALBERT on 09/06/2023.
//  All rights reserved.
//----------------------------------------------------

import Foundation
import CoreData
import CrewmateCore

/// A singleton for managing the CoreData stacks.
///
/// Main context should be used for UI and read operations.
/// Write operations can be performed in background by enqueuing them using `enqueueBackgroundTask()` functions.
/// Each background operation is performed one at a time using an operation queue to avoid conflicts.
/// You can use a shared queue for synchronizing background operations between different stacks.
///
public final class CoreDataStack: @unchecked Sendable {
    
    /// The store container URL.
    public let containerURL: URL
    
    public init(modelName: String, containerURL: URL, spotlightDomainIdentifier: String? = nil, backgroundQueue: OperationQueue? = nil) {
        self.modelName = modelName
        self.containerURL = containerURL
        testingMode = false
        self.spotlightDomainIdentifier = spotlightDomainIdentifier
        self.backgroundQueue = backgroundQueue ?? Self.newBackgroundQueue()
        persistentContainer = NSPersistentContainer(name: modelName) // temporary value until setupContainer() is called
    }
    
    /// Setting-up the CoreData stack.
    ///
    /// - Parameter testingMode: A boolean indicating wether the CoreData stack should be setup for testing mode.
    /// - Parameter preSeededStoreURL: The URL of the pre-seeded sqlite file to use when store does not exist yet.
    ///
    /// - Important: You should wait for the `isReady` flag to be set before performing CoreData requests.
    public func setup(forTesting testingMode: Bool = false, preSeededStoreURL: URL? = nil) {
        
        setupLock.lock()
        defer { setupLock.unlock() }
        
        guard !isSetup else {
            return
        }
        
        Self.allStacks.append(self)
        self.testingMode = testingMode
        setupContainer(preSeededStoreURL: preSeededStoreURL)
        
        isSetup = true
    }
    
    /// Indicates whether the CoreData stack is ready for
    /// performing read/write operations.
    public private(set) var isReady = false
    
    /// The persistent container.
    ///
    /// - Important: You must not keep strong references to the persistent container,
    /// as it can be recreated at anytime (on user log out, for example).
    public private(set) var persistentContainer: NSPersistentContainer
    
    
    /// The Spotlight indexing domain identifier (`nil` when Spotlight indexing is disabled).
    public let spotlightDomainIdentifier: String?
    /// Indicates whether Spotlight indexing is enabled.
    public var isIndexableOnSpotlight: Bool {
        spotlightDomainIdentifier != nil
    }
    /// The Spotlight delegate (only available for `main` instance).
    public private(set) var spotlightDelegate: CoreDataSpotlightDelegate?
    
    /// Getting the corresponding `CoreDataStack` for a given context.
    ///
    /// - Parameter context: The CoreData context.
    ///
    /// - Returns: The corresponding `CoreDataStack`.
    public static func stack(for context: NSManagedObjectContext) -> CoreDataStack {
        allStacks.first {
            $0.persistentContainer.persistentStoreCoordinator == context.persistentStoreCoordinator
        }!
    }
    
    /// Getting the stack a given CoreDataObject type belongs to.
    ///
    /// - Parameter objectType: The CoreDataObject type.
    ///
    /// - Returns: The corresponding stack.
    public static func stack(for objectType: CoreDataObject.Type) -> CoreDataStack {
        let stack = allStacks.first {
            $0.persistentContainer.managedObjectModel.entities.contains { entity in
                entity.name == objectType.entityName
            }
        }
        guard let stack else {
            fatalError("CoreDataStack for '\(objectType)' not found")
        }
        return stack
    }
    
    /// Getting the stack a given CoreDataObject belongs to.
    ///
    /// - Parameter object: The CoreData object.
    ///
    /// - Returns: The corresponding stack.
    public static func stack<T: CoreDataObject>(for object: T) -> CoreDataStack {
        let stack = allStacks.first {
            $0.persistentContainer.managedObjectModel.entities.contains { entity in
                entity.name == object.entity.name
            }
        }
        guard let stack else {
            fatalError("CoreDataStack for '\(object)' not found")
        }
        return stack
    }
    
    
    //--------------------
    // MARK: Main Context
    //--------------------
    
    /// The main context (should only be accessed within main thread).
    ///
    /// - Important: You must not keep strong references to the main context,
    /// as it can be recreated at anytime (on user log out, for example).
    public var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    /// Saving the main context (thread-safe).
    public func saveMainContext() throws {
        try mainContext.saveSafely()
    }
    
    
    //------------------------
    // MARK: Background Tasks
    //------------------------

    /// Creating a new background context.
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = mergePolicy
        return context
    }
    
    /// Performing a background task.
    ///
    /// - Parameter task: The task to perform using the provided context.
    public func enqueueBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        backgroundQueue.addOperation { [unowned self] in
            let context = newBackgroundContext()
            context.performAndWait {
                task(context)
            }
        }
    }

    /// Performing a background task (`async` version).
    ///
    /// - Parameter task: The task to perform using the provided context.
    public func enqueueBackgroundTask(_ task: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            backgroundQueue.addOperation { [unowned self] in
                let context = newBackgroundContext()
                context.performAndWait {
                    do {
                        try task(context)
                        continuation.resume()
                    }
                    catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    /// Performing a background task (`async` version with a return value).
    ///
    /// - Parameter task: The task to perform using the provided context.
    ///
    /// - Returns: The task return value.
    public func enqueueBackgroundTask<T>(_ task: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            backgroundQueue.addOperation { [unowned self] in
                let context = newBackgroundContext()
                context.performAndWait {
                    do {
                        let value = try task(context)
                        continuation.resume(returning: value)
                    }
                    catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    
    //----------------------
    // MARK: Clearing Store
    //----------------------
    
    /// Clearing all CoreData instances.
    ///
    /// - Parameter typesToKeep: The instances types that should be kept.
    /// - Parameter context: The CoreData context.
    ///
    /// - Note: Kept types include all their sub-entities.
    public func clearStore(except typesToKeep: [CoreDataObject.Type] = [], in context: NSManagedObjectContext) throws {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else { return }
        
        try context.performAndWait {
            
            let entitiesToKeep = typesToKeep.flatMap {
                let entity = $0.entity()
                return [entity] + entity.allSubentities
            }
            
//            Log.info("Clearing CoreData store...")
            
            for entity in model.entities where !entitiesToKeep.contains(entity) {
                guard let entityName = entity.name else { continue }
                
                if testingMode {
                    let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
                    let objects = try context.fetch(fetch)
                    objects.forEach { context.delete($0) }
                }
                else {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(batchDeleteRequest)
                }
            }
            
            try context.save()
        }
    }
    
    /// Deleting and regenerating the CoreData store. This physically destroy the stores files and creates new ones.
    public func destroyStore() {
        
        let storeCoordinator = persistentContainer.persistentStoreCoordinator
        for store in storeCoordinator.persistentStores {
            try? storeCoordinator.destroyPersistentStore(at: store.url!, ofType: store.type)
        }
        
//        Log.info("Did destroy CoreData store")
        
        setupContainer()
    }
    
    
    //-----------------------
    // MARK: Exporting Store
    //-----------------------
    
    /// Exporting the SQLITE store file.
    ///
    /// - Returns: The `.sqlite` file URL.
    public func exportSqliteStore() throws -> URL {
        
        try saveMainContext()
        
        let coordinator = persistentContainer.persistentStoreCoordinator
        let store = coordinator.persistentStores.first!
        try coordinator.remove(store)
        
        let storeURL = store.url!
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: [ NSSQLitePragmasOption: [ "journal_mode" : "DELETE" ] ]
        )
        
        return storeURL
    }
    
    
    //---------------
    // MARK: Private
    //---------------
    
    nonisolated(unsafe) private static var allStacks = [CoreDataStack]()
    
    private let modelName: String
    private var testingMode: Bool
    private var setupLock = NSLock()
    private var isSetup = false
    
    private let mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    
    private let backgroundQueue: OperationQueue
    
    private static func newBackgroundQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
    
    private func setupContainer(preSeededStoreURL: URL? = nil) {
        
        isReady = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let container = NSPersistentContainer(name: modelName)
        
        let storeDescription = container.persistentStoreDescriptions.first!
//        if isIndexableOnSpotlight && !testingMode {
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        }
        if testingMode {
            storeDescription.type = NSInMemoryStoreType
        }
        
        let storeURL = containerURL.appending(component: modelName + ".sqlite")
        
        if !FileManager.default.fileExists(atPath: storeURL.path(percentEncoded: false)),
           let preSeededStoreURL, FileManager.default.fileExists(atPath: preSeededStoreURL.path(percentEncoded: false)) {
            
            do {
                try FileManager.default.copyItem(at: preSeededStoreURL, to: storeURL)
//                Log.debug("Use pre-seeded store for '\(modelName)'")
            }
            catch {
//                Log.warning("Did fail to use pre-seeded store for '\(modelName)' with error: \(error.localizedDescription)")
            }
        }
        storeDescription.url = storeURL
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Did fail to load persistent container with error: \(error.localizedDescription)")
            }
            self.isReady = true
            semaphore.signal()
        }
        
        semaphore.wait()
        
        container.viewContext.mergePolicy = mergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        persistentContainer = container
        
        if let spotlightDomainIdentifier, !testingMode { // TODO: Thread-issue to fix
            spotlightDelegate = CoreDataSpotlightDelegate(
                for: container,
                domainIdentifier: spotlightDomainIdentifier
            )
            spotlightDelegate?.startSpotlightIndexing()
        }
    }
}

extension CoreDataStack: CustomStringConvertible {
    
    public var description: String {
        DebugDescription(for: self, [modelName]).description
    }
}

extension NSManagedObjectContext {
    
    /// Saving context safely (thread-safe).
    public func saveSafely() throws {
        try performAndWait {
            if hasChanges {
                try save()
            }
        }
    }

    public func saveAsSoonAsPossible() {
        let key = ObjectIdentifier(self)
        Self.saveLock.lock()
        
        Self.saveWorkItems[key]?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            try? self?.saveSafely()
            Self.saveLock.lock()
            Self.saveWorkItems.removeValue(forKey: key)
            Self.saveLock.unlock()
        }
        
        Self.saveWorkItems[key] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
        Self.saveLock.unlock()
    }
    
    private static let saveLock = NSLock()
    nonisolated(unsafe) private static var saveWorkItems = [ObjectIdentifier:DispatchWorkItem]()
}

extension NSEntityDescription {
    
    /// All subentities (recursively).
    var allSubentities: [NSEntityDescription] {
        var entities = [NSEntityDescription]()
        entities.append(contentsOf: subentities)
        for entity in subentities {
            entities.append(contentsOf: entity.allSubentities)
        }
        return entities
    }
}
