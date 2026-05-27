//----------------------------------------------------
//  CoreDataSpotlightDelegate.swift
//
//  Created by Thomas ALBERT on 06/09/2023.
//  All rights reserved.
//----------------------------------------------------

import Foundation
import CoreData
import CoreSpotlight

public typealias SpotlightAttributeSet = CSSearchableItemAttributeSet

/// A protocol to adopt by CoreData objects that should be indexable in Spotlight.
///
public protocol SpotlightIndexable: CoreDataObject {
    
    /// Generating the attribute set for Spotlight indexing.
    func spotlightAttributeSet() -> SpotlightAttributeSet?
    
    /// Presenting the detail view controller from a Spotlight search.
    func presentFromSpotlight()
}

/// The CoreData-Spotlight delegate for auto-indexing items.
///
public final class CoreDataSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {
    
    let container: NSPersistentContainer
    
    required init(for container: NSPersistentContainer, domainIdentifier: String) {
        self.container = container
        domainID = domainIdentifier
        
        super.init(forStoreWith: container.persistentStoreDescriptions.first!, coordinator: container.persistentStoreCoordinator)
    }
    
    /// Handling a given user activity.
    ///
    /// - Parameter userActivity: The activity to handle.
    public func handle(userActivity: NSUserActivity) {
        
        guard userActivity.activityType == CSSearchableItemActionType,
            let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
            let objectID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: identifier)!),
            let object = container.viewContext.object(with: objectID) as? SpotlightIndexable else {
            return
        }
        
        object.presentFromSpotlight()
    }
    
    
    //---------------------------------------
    // MARK: NSCoreDataCoreSpotlightDelegate
    //---------------------------------------
    
    public override func domainIdentifier() -> String {
        
        domainID
    }
    
    public override func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
        
        (object as? SpotlightIndexable)?.spotlightAttributeSet()
    }
    
    private let domainID: String
}
