//
//  Errors.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 20/12/2025.
//

import Foundation

/// An extension for using `String` as errors (for debug purposes only).
/// It's declared as @@retroactive because both String, Error and LocalizedError are imported types
/// so if Apple add this conformance in a future version of Swift, there might be some issues.
///
extension String: @retroactive Error {}
extension String: @retroactive LocalizedError {
    public var errorDescription: String? { self }
}

/// A protocol to adopt by `Error` enums to provide detailed descriptions for easier debugging in both Debug and Release builds.
///
/// Adopting this protocol ensures that the error type, case name, and associated values
/// are always printed in a consistent and readable format.
///
/// Because Release builds are optimized, when you try to log an `Error` which is not `CustomStringConvertible`
/// it will probably print something like `Crewmate.CrewmateAPIError error 4` instead of `internalError(code: 502)`.
/// Plus, when printing errors with default behavior, the enum type (`CrewmateAPIError` in this example) is not printed so it
/// can be confusing. Adopting this protocol makes sure to always print the errors the same way in Debug/Release
/// builds, including error type, case name and associated values: `CrewmateAPIError.internalError(code: 502)`.
///
public protocol DebuggableError: LocalizedError, CustomStringConvertible {
}
public extension DebuggableError {
    
    var localizedDescription: String {
        description
    }
    
    var errorDescription: String? {
        description
    }
    
    var description: String {
        let mirror = Mirror(reflecting: self)
        
        // Enums with associated values
        if let child = mirror.children.first {
            guard let label = child.label else {
                return "Unknown"
            }
            return "\(Self.self).\(label)(\((child.value as? CustomStringConvertible)?.description ?? "\(child.value)"))"
        }
        
        // Enums without associated values
        guard let stringPtr = enumCaseName(self),
              let caseName = String(validatingCString: stringPtr) else {
            return "Unknown"
        }
        
        return "\(Self.self).\(caseName)"
    }
    
    @_silgen_name("swift_EnumCaseName")
    private func enumCaseName<T>(_ value: T) -> UnsafePointer<CChar>?
}
