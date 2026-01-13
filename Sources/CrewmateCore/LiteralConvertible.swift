//
//  LiteralConvertible.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 13/01/2026.
//

import Foundation

/// A protocol to adopt by objects that can be initialized from a `String` literal.
public protocol LiteralInitializable {
    
    /// Creates an instance from its literal representation.
    init(_ literal: String) throws
}

public protocol LiteralConvertible: LiteralInitializable {
    
    /// The literal representation.
    var literal: String { get }
}
