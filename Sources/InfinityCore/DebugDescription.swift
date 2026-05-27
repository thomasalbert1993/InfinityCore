//
//  DebugDescription.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 15/01/2026.
//

import Foundation

/// A helper structure for generating readable debug descriptions of objects.
/// It automatically includes the object's type and optional identifying components.
public struct DebugDescription: Hashable, Sendable, CustomStringConvertible {
    
    /// The type name of the object being described.
    public var objectType: String
    
    /// A list of components to include in the description.
    public var components: [String]
    
    /// Creates a debug description for the given object with multiple components.
    ///
    /// - Parameter object: The object to describe.
    /// - Parameter components: An optional list of components describing the object.
    ///
    /// If the object conforms to `Identifiable`, its `id` will automatically
    /// be included as the first component.
    public init<T>(for object: T, _ components: [String] = []) {
        objectType = "\(type(of: object))"
        self.components = components
        
        if let object = object as? any Identifiable {
            self.components.insert("ID: \(object.id)", at: 0)
        }
    }
    
    /// Creates a debug description for the given object with a single component.
    ///
    /// - Parameter object: The object to describe.
    /// - Parameter component: A single descriptive component.
    public init<T>(for object: T, _ component: String) {
        self.init(for: object, [component])
    }
    
    
    //---------------------------------
    // MARK: <CustomStringConvertible>
    //---------------------------------
    
    public var description: String {
        "\(objectType)(\(components.joined(separator: " - ")))"
    }
}
