//
//  Core.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 20/12/2025.
//

import Foundation

/// An helper operator that throws a given error when left value is `nil`.
///
/// Example of use:
/// ```
/// let instance = try Asset.fetch(id: "MyID") ?! CoreDataError.instanceNotFound(id: "MyID")
/// ```
/// Is an equivalent of:
/// ```
/// guard let instance = Asset.fetch(id: "MyID") else {
///     throw CoreDataError.instanceNotFound(id: "MyID")
/// }
/// ```
infix operator ?!
public func ?!<T>(lhs: T?, rhs: @autoclosure () -> Error) throws -> T {
    guard let lhs else {
        throw rhs()
    }
    return lhs
}
