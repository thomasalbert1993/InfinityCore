//----------------------------------------------------
//  JSON.swift
//
//  Created by Thomas ALBERT on 20/12/2025.
//  All rights reserved.
//----------------------------------------------------

import Foundation

/// A type-safe representation of any valid JSON value.
///
/// `JSONValue` mirrors the JSON data model and can represent null value,
/// booleans, numbers, strings, arrays, and objects. It is commonly used
/// as an intermediate type when parsing, encoding, or manipulating JSON
/// without losing structural information.
public indirect enum JSONValue: Hashable, Sendable {
    /// A wrapped null value.
    case null
    /// A wrapped `Bool` value.
    case bool(Bool)
    /// A wrapped `Double` value.
    case number(Double)
    /// A wrapped `String` value.
    case string(String)
    /// A wrapped array of `JSONValue`.
    case array([JSONValue])
    /// A wrapped `JSONObject`.
    case object(JSONObject)
}

public extension JSONValue {
    
    /// Returns the given `JSONValue` or `.null` when `nil`.
    static func optional(_ value: JSONValue?) -> Self {
        value != nil ? value! : .null
    }
    
    /// Returns the given `.bool` value or `.null` when `nil`.
    static func optionalBool(_ bool: Bool?) -> Self {
        bool != nil ? .bool(bool!) : .null
    }
    
    /// Returns the given `.number` value or `.null` when `nil`.
    static func optionalNumber(_ number: Double?) -> Self {
        number != nil ? .number(number!) : .null
    }
    
    /// Returns the given `.string` value or `.null` when `nil`.
    static func optionalString(_ string: String?) -> Self {
        string != nil ? .string(string!) : .null
    }
    
    /// Returns the given `.array` value or `.null` when `nil`.
    static func optionalArray(_ array: [JSONValue]?) -> Self {
        array != nil ? .array(array!) : .null
    }
    
    /// Returns the given `.object` value or `.null` when `nil`.
    static func optionalObject(_ object: JSONObject?) -> Self {
        object != nil ? .object(object!) : .null
    }
    
    /// Returns `self` when `condition` passes, otherwise `.null`.
    func when(_ condition: @autoclosure () -> Bool) -> Self {
        condition() ? self : .null
    }
    
    /// Converts `null` value to `nil`.
    var nullAsNil: JSONValue? {
        self == .null ? nil : self
    }
    
    /// The corresponding `Bool` value. 0 and 1 numbers are allowed.
    var boolValue: Bool {
        get throws {
            try boolValue(orThrow: "Invalid value (expected Bool)")
        }
    }
    
    /// The corresponding `Int` value. Only non-fractional numbers are allowed.
    var intValue: Int {
        get throws {
            try intValue(orThrow: "Invalid value (expected Int)")
        }
    }
    
    /// The corresponding `Double` value.
    var doubleValue: Double {
        get throws {
            try doubleValue(orThrow: "Invalid value (expected Double)")
        }
    }
    
    /// The corresponding `String` value.
    var stringValue: String {
        get throws {
            try stringValue(orThrow: "Invalid value (expected String)")
        }
    }
    
    /// The corresponding `[JSONValue]` value.
    var arrayValue: [JSONValue] {
        get throws {
            try arrayValue(orThrow: "Invalid value (expected [JSONValue])")
        }
    }
    
    /// The corresponding `JSONObject` value.
    var objectValue: JSONObject {
        get throws {
            try objectValue(orThrow: "Invalid value (expected JSONObject)")
        }
    }
    
    /// Checks whether it's equal to a given `JSONValue`.
    ///
    /// - Parameter value: The `JSONValue` to compare.
    /// - Parameter handleArraysAsSets: A boolean indicating whether the arrays should
    /// be handled as sets (ie. ignoring order and duplicates).
    ///
    /// - Returns: `true` if the two values are identical.
    func isEqual(to value: Self, handleArraysAsSets: Bool = false) -> Bool {
        if handleArraysAsSets {
            switch (self, value) {
                
                case (.array(let lhs), .array(let rhs)):
                    
                    // Every element in lhs must exist in rhs
                    for item in lhs {
                        if !rhs.contains(where: { item.isEqual(to: $0, handleArraysAsSets: true) }) {
                            return false
                        }
                    }
                    
                    // Every element in rhs must exist in lhs
                    for item in rhs {
                        if !lhs.contains(where: { item.isEqual(to: $0, handleArraysAsSets: true) }) {
                            return false
                        }
                    }
                    
                    return true
                
                case (.object(let lhs), .object(let rhs)):
                    
                    guard lhs.count == rhs.count else {
                        return false
                    }
                    
                    for (key, lhsValue) in lhs {
                        guard let rhsValue = rhs[key], rhsValue.isEqual(to: lhsValue, handleArraysAsSets: true) else {
                            return false
                        }
                    }
                    
                    return true
                    
                default:
                    break
            }
        }
        return self == value
    }
}

extension JSONValue: RawRepresentable {
    
    public var rawValue: Any {
        switch self {
            case .null:
                return NSNull()
            case .bool(let bool):
                return bool
            case .number(let number):
                return number
            case .string(let string):
                return string
            case .array(let array):
                return array.map { $0.rawValue }
            case .object(let object):
                return object.mapValues { $0.rawValue }
        }
    }
    
    public init?(rawValue: Any) {
        switch rawValue {
            
            case let value as Self:
                self = value
            
            case is NSNull:
                self = .null
            
            case let value as Bool:
                self = .bool(value)
                
            case let value as NSNumber:
                self = .number(value.doubleValue)
                
            case let value as String:
                self = .string(value)
                
            case let value as [Any]:
                var array = [JSONValue]()
                for item in value {
                    guard let item = Self(rawValue: item) else {
                        return nil
                    }
                    array.append(item)
                }
                self = .array(array)
                
            case let value as [String:Any]:
                var object = JSONObject()
                for (key, item) in value {
                    guard let value = Self(rawValue: item) else {
                        return nil
                    }
                    object[key] = value
                }
                self = .object(object)
                
            default:
                return nil
        }
    }
}

/// A type-safe representation of a JSON object.
public typealias JSONObject = [String:JSONValue]

extension JSONObject: @retroactive RawRepresentable {
    
    public var rawValue: [String:Any] {
        mapValues { $0.rawValue }
    }
    
    public init?(rawValue: [String:Any]) {
        var object = JSONObject()
        for (key, item) in rawValue {
            guard let value = JSONValue(rawValue: item) else {
                return nil
            }
            object[key] = value
        }
        self = object
    }
}

extension JSONValue: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode(JSONObject.self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid JSON value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .null: try container.encodeNil()
            case .bool(let bool): try container.encode(bool)
            case .number(let number): try container.encode(number)
            case .string(let string): try container.encode(string)
            case .array(let array): try container.encode(array)
            case .object(let object): try container.encode(object)
        }
    }
}

/// A protocol that marks a type as convertible to a `JSONValue`.
///
/// `JSONValueConvertible` is a convenience abstraction that allows common
/// Foundation and Swift types to be automatically converted into
/// `JSONValue` instances. It enables ergonomic construction of JSON
/// structures using native Swift literals and collections.
///
/// The following types conform by default:
/// - `JSONValue`
/// - `NSNull`
/// - `Bool`
/// - `Int` (converted to `.number(Double)`)
/// - `Double`
/// - `String`
/// - Arrays whose elements conform to `JSONValueConvertible`
/// - Dictionaries whose values conform to `JSONValueConvertible`
///
/// - Important: You should never make any other type conforming to this protocol.
public protocol JSONValueConvertible {}
extension JSONValue: JSONValueConvertible {}
extension NSNull: JSONValueConvertible {}
extension Bool: JSONValueConvertible {}
extension Int: JSONValueConvertible {}
extension Double: JSONValueConvertible {}
extension String: JSONValueConvertible {}
extension Array: JSONValueConvertible where Element: JSONValueConvertible {}
extension Dictionary: JSONValueConvertible where Value: JSONValueConvertible {}

extension JSONValueConvertible {
    
    /// The equivalent `JSONValue` instance.
    public var jsonValue: JSONValue {
        switch self {
            case let value as JSONValue:
                return value
            case is NSNull:
                return .null
            case let bool as Bool:
                return .bool(bool)
            case let int as Int:
                return .number(Double(int))
            case let double as Double:
                return .number(double)
            case let string as String:
                return .string(string)
            case let array as [JSONValueConvertible]:
                return .array(array.map { $0.jsonValue })
            case let object as [String:JSONValueConvertible]:
                return .object(object.mapValues { $0.jsonValue })
            default:
                fatalError("Invalid JSONValueProtocol value (should be JSONValue, NSNull, Bool, Int, Double, String, [JSONValueConvertible] or [String:[JSONValueConvertible]")
        }
    }
    
    /// Checks whether it's equal to a given `JSONValueConvertible`.
    ///
    /// - Parameter value: The `JSONValueConvertible` to compare.
    /// - Parameter handleArraysAsSets: A boolean indicating whether the arrays should
    /// be handled as sets (ie. ignoring order and duplicates).
    ///
    /// - Returns: `true` if the two values are identical.
    public func isEqual(to value: JSONValueConvertible, handleArraysAsSets: Bool = false) -> Bool {
        jsonValue.isEqual(to: value.jsonValue, handleArraysAsSets: handleArraysAsSets)
    }
}

extension JSONValue {
    
    public init(_ rawValue: JSONValueConvertible) {
        self.init(rawValue: rawValue)!
    }
}

extension JSONObject {
    
    /// Creates a `JSONObject` from a dictionary of optional JSON-compatible values.
    ///
    /// Any `nil` values in the input dictionary are automatically converted
    /// to `.null`, allowing callers to express JSON `null` values naturally
    /// using Swift optionals.
    ///
    /// - Parameter rawValue: A dictionary whose values are optional `JSONValueConvertible` instances.
    public init(_ rawValue: [String:JSONValueConvertible?]) {
        self = .init(rawValue: rawValue.mapValues {
            $0 != nil ? $0 : NSNull()
        })!
    }
}

extension JSONValue {
    
    /// Converts to CoreData storable value.
    public var coreDataStorable: Any {
        switch self {
            case .null: return NSNull()
            case .bool(let bool): return NSNumber(value: bool)
            case .number(let number): return NSNumber(value: number)
            case .string(let string): return NSString(string: string)
            case .array(let array): return array.map { $0.coreDataStorable }
            case .object(let object): return object.mapValues { $0.coreDataStorable }
        }
    }
}

extension JSONObject {
    
    /// Converts to CoreData storable value.
    public var coreDataStorable: [String:Any] {
        mapValues { $0.coreDataStorable }
    }
}

extension JSONObject {
    
    /// Creates a `JSONObject` from raw `Data`.
    ///
    /// - Parameter data: The input data.
    public init(data: Data) throws {
        guard let content = try JSONSerialization.jsonObject(with: data) as? [String:Any],
              let object = Self(rawValue: content) else {
            throw "Unable to unserialize data to JSONObject"
        }
        self = object
    }
    
    /// Removes any `.null` value from object.
    public func removingNullValues() -> Self {
        filter { $0.value != .null }
    }
    
    
    //---------------------------
    // MARK: Serializing Objects
    //---------------------------
    
    /// Serializes a `JSONObject` into a `String`.
    ///
    /// - Parameter prettyPrinted: A boolean indicating whether the output should be human readable (ie. with line breaks and tabs).
    ///
    /// - Returns: The serialized object as `String`.
    public func serialized(prettyPrinted: Bool = false) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: rawValue, options: prettyPrinted ? .prettyPrinted : [])
        guard let string = String(data: data, encoding: .utf8) else {
            throw "Unable to serialize JSONObject: \(self)"
        }
        return string
    }
}

extension JSONObject {
    
    public func value(forKey key: String) throws -> JSONValue {
        guard let value = try optionalValue(forKey: key) else {
            throw "Missing or null value for key '\(key)' in \(self)"
        }
        return value
    }
    
    public func array(forKey key: String) throws -> [JSONValue] {
        try value(forKey: key).arrayValue(orThrow: "Invalid value for key '\(key)' (expected Array) in \(self)")
    }
    
    public func string(forKey key: String) throws -> String {
        try value(forKey: key).stringValue(orThrow: "Invalid value for key '\(key)' (expected String) in \(self)")
    }
    
    public func stringArray(forKey key: String) throws -> [String] {
        try value(forKey: key).arrayValue(orThrow: "Invalid value for key '\(key)' (expected [String]) in \(self)").map {
            try $0.stringValue(orThrow: "Invalid value for key '\(key)' (expected [String]) in \(self)")
        }
    }
    
    public func int(forKey key: String) throws -> Int {
        try value(forKey: key).intValue(orThrow: "Invalid value for key '\(key)' (expected Int) in \(self)")
    }
    
    public func intArray(forKey key: String) throws -> [Int] {
        try value(forKey: key).arrayValue(orThrow: "Invalid value for key '\(key)' (expected [Int]) in \(self)").map {
            try $0.intValue(orThrow: "Invalid value for key '\(key)' (expected [Int]) in \(self)")
        }
    }
    
    public func bool(forKey key: String) throws -> Bool {
        try value(forKey: key).boolValue(orThrow: "Invalid value for key '\(key)' (expected Bool) in \(self)")
    }
    
    public func boolArray(forKey key: String) throws -> [Bool] {
        try value(forKey: key).arrayValue(orThrow: "Invalid value for key '\(key)' (expected [Bool]) in \(self)").map {
            try $0.boolValue(orThrow: "Invalid value for key '\(key)' (expected [Bool]) in \(self)")
        }
    }
    
    public func double(forKey key: String) throws -> Double {
        try value(forKey: key).doubleValue(orThrow: "Invalid value for key '\(key)' (expected Double) in \(self)")
    }
    
    public func doubleArray(forKey key: String) throws -> [Double] {
        try value(forKey: key).arrayValue(orThrow: "Invalid value for key '\(key)' (expected [Double]) in \(self)").map {
            try $0.doubleValue(orThrow: "Invalid value for key '\(key)' (expected [Double]) in \(self)")
        }
    }
    
    public func object(forKey key: String) throws -> JSONObject {
        try value(forKey: key).objectValue(orThrow: "Invalid value for key '\(key)' (expected JSONObject) in \(self)")
    }
    
    public func object<T: JSONInitializable>(forKey key: String, type: T.Type) throws -> T {
        try T(from: object(forKey: key))
    }
    
    public func object<T: JSONInitializable>(forKey key: String) throws -> T {
        try T(from: object(forKey: key))
    }
    
    public func object<T: LiteralInitializable>(forKey key: String, type: T.Type) throws -> T {
        try T(string(forKey: key))
    }
    
    public func object<T: LiteralInitializable>(forKey key: String) throws -> T {
        try T(string(forKey: key))
    }
    
    public func objectArray(forKey key: String) throws -> [JSONObject] {
        try value(forKey: key).arrayValue(orThrow: "Invalid value for key '\(key)' (expected [JSONObject]) in \(self)").map {
            try $0.objectValue(orThrow: "Invalid value for key '\(key)' (expected [JSONObject]) in \(self)")
        }
    }
    
    public func objectArray<T: JSONInitializable>(forKey key: String, type: T.Type) throws -> [T] {
        try objectArray(forKey: key).map {
            try T(from: $0)
        }
    }
    
    public func objectArray<T: JSONInitializable>(forKey key: String) throws -> [T] {
        try objectArray(forKey: key).map {
            try T(from: $0)
        }
    }
    
    public func objectArray<T: LiteralInitializable>(forKey key: String, type: T.Type) throws -> [T] {
        try stringArray(forKey: key).map {
            try T($0)
        }
    }
    
    public func objectArray<T: LiteralInitializable>(forKey key: String) throws -> [T] {
        try stringArray(forKey: key).map {
            try T($0)
        }
    }
    
    public func date(forKey key: String) throws -> Date {
        try string(forKey: key).toDate()
    }
    
    public func dateArray(forKey key: String) throws -> [Date] {
        try stringArray(forKey: key).map{ try $0.toDate() }
    }
    
    public func optionalValue(forKey key: String) throws -> JSONValue? {
        self[key]?.nullAsNil
    }
    
    public func optionalArray(forKey key: String) throws -> [JSONValue]? {
        try optionalValue(forKey: key)?.arrayValue(orThrow: "Invalid value for key '\(key)' (expected Array?) in \(self)")
    }
    
    public func optionalString(forKey key: String) throws -> String? {
        try optionalValue(forKey: key)?.stringValue(orThrow: "Invalid value for key '\(key)' (expected String?) in \(self)")
    }
    
    public func optionalStringArray(forKey key: String) throws -> [String]? {
        try optionalValue(forKey: key)?.arrayValue(orThrow: "Invalid value for key '\(key)' (expected [String]?) in \(self)").map {
            try $0.stringValue(orThrow: "Invalid value for key '\(key)' (expected [String]?) in \(self)")
        }
    }
    
    public func optionalInt(forKey key: String) throws -> Int? {
        try optionalValue(forKey: key)?.intValue(orThrow: "Invalid value for key '\(key)' (expected Int?) in \(self)")
    }
    
    public func optionalIntArray(forKey key: String) throws -> [Int]? {
        try optionalValue(forKey: key)?.arrayValue(orThrow: "Invalid value for key '\(key)' (expected [Int]?) in \(self)").map {
            try $0.intValue(orThrow: "Invalid value for key '\(key)' (expected [Int]?) in \(self)")
        }
    }
    
    public func optionalBool(forKey key: String) throws -> Bool? {
        try optionalValue(forKey: key)?.boolValue(orThrow: "Invalid value for key '\(key)' (expected Bool?) in \(self)")
    }
    
    public func optionalBoolArray(forKey key: String) throws -> [Bool]? {
        try optionalValue(forKey: key)?.arrayValue(orThrow: "Invalid value for key '\(key)' (expected [Bool]?) in \(self)").map {
            try $0.boolValue(orThrow: "Invalid value for key '\(key)' (expected [Bool]?) in \(self)")
        }
    }
    
    public func optionalDouble(forKey key: String) throws -> Double? {
        try optionalValue(forKey: key)?.doubleValue(orThrow: "Invalid value for key '\(key)' (expected Double?) in \(self)")
    }
    
    public func optionalDoubleArray(forKey key: String) throws -> [Double]? {
        try optionalValue(forKey: key)?.arrayValue(orThrow: "Invalid value for key '\(key)' (expected [Double]?) in \(self)").map {
            try $0.doubleValue(orThrow: "Invalid value for key '\(key)' (expected [Double]?) in \(self)")
        }
    }
    
    public func optionalObject(forKey key: String) throws -> JSONObject? {
        try optionalValue(forKey: key)?.objectValue(orThrow: "Invalid value for key '\(key)' (expected JSONObject?) in \(self)")
    }
    
    public func optionalObject<T: JSONInitializable>(forKey key: String, type: T.Type) throws -> T? {
        try optionalObject(forKey: key)?.to(T.self)
    }
    
    public func optionalObject<T: JSONInitializable>(forKey key: String) throws -> T? {
        try optionalObject(forKey: key)?.to(T.self)
    }
    
    public func optionalObject<T: LiteralInitializable>(forKey key: String, type: T.Type) throws -> T? {
        if let literal = try optionalString(forKey: key) {
            return try T(literal)
        }
        return nil
    }
    
    public func optionalObject<T: LiteralInitializable>(forKey key: String) throws -> T? {
        if let literal = try optionalString(forKey: key) {
            return try T(literal)
        }
        return nil
    }
    
    public func optionalObjectArray(forKey key: String) throws -> [JSONObject]? {
        try optionalValue(forKey: key)?.arrayValue(orThrow: "Invalid value for key '\(key)' (expected [JSONObject]?) in \(self)").map {
            try $0.objectValue(orThrow: "Invalid value for key '\(key)' (expected [JSONObject]?) in \(self)")
        }
    }
    
    public func optionalObjectArray<T: JSONInitializable>(forKey key: String, type: T.Type) throws -> [T]? {
        try optionalObjectArray(forKey: key)?.map {
            try T(from: $0)
        }
    }
    
    public func optionalObjectArray<T: JSONInitializable>(forKey key: String) throws -> [T]? {
        try optionalObjectArray(forKey: key)?.map {
            try T(from: $0)
        }
    }
    
    public func optionalObjectArray<T: LiteralInitializable>(forKey key: String, type: T.Type) throws -> [T]? {
        try optionalStringArray(forKey: key)?.map {
            try T($0)
        }
    }
    
    public func optionalObjectArray<T: LiteralInitializable>(forKey key: String) throws -> [T]? {
        try optionalStringArray(forKey: key)?.map {
            try T($0)
        }
    }
    
    public func optionalDate(forKey key: String) throws -> Date? {
        try optionalString(forKey: key)?.toDate()
    }
    
    public func optionalDateArray(forKey key: String) throws -> [Date]? {
        try optionalStringArray(forKey: key)?.map { try $0.toDate() }
    }
    
    // RawRepresentable
    
    public func rawRepresentable<T: RawRepresentable>(forKey key: String) throws -> T where T.RawValue == String {
        let rawValue = try string(forKey: key)
        guard let value = T.init(rawValue: rawValue) else {
            throw "Did fail to create \(T.self) value from raw value '\(rawValue)'"
        }
        return value
    }
    
    public func optionalRawRepresentable<T: RawRepresentable>(forKey key: String) throws -> T? where T.RawValue == String {
        if let rawValue = try optionalString(forKey: key) {
            return .init(rawValue: rawValue)
        }
        return nil
    }
    
    // JSONInitializable
    
    /// Converting a `JSONObject` into a given `JSONInitializable` instance.
    ///
    /// - Parameter type: The instance type.
    ///
    /// - Returns: The created instance.
    public func instance<T: JSONInitializable>(_ type: T.Type) throws -> T {
        try T(from: self)
    }
    
    /// Converting a `JSONObject` into a given `JSONInitializable` instance.
    ///
    /// - Returns: The created instance (type is inherited from return type).
    public func instance<T: JSONInitializable>() throws -> T {
        try instance(T.self)
    }
}

extension JSONObject {
    
    /// Converting to a given `JSONInitializable` object.
    ///
    /// - Parameter type: The object type.
    ///
    /// - Returns: The initialized object.
    public func to<T: JSONInitializable>(_ type: T.Type) throws -> T {
        try T.init(from: self)
    }
}

extension [String:Any] {
    
    /// Converting a regular key/value dictionary into a `JSONObject`.
    ///
    /// - Returns: The converted JSON object.
    public func toJSON() throws -> JSONObject {
        try JSONObject(rawValue: self) ?! "Invalid value"
    }
    
    /// Converting a regular key/value dictionary into a given `JSONInitializable` instance.
    ///
    /// - Parameter type: The instance type.
    ///
    /// - Returns: The created instance.
    public func instance<T: JSONInitializable>(_ type: T.Type) throws -> T {
        try toJSON().instance(type)
    }
    
    /// Converting a regular key/value dictionary into a given `JSONInitializable` instance.
    ///
    /// - Returns: The created instance (type is inherited from return type).
    public func instance<T: JSONInitializable>() throws -> T {
        try instance(T.self)
    }
}


/// A protocol to adopt for making an object encodable to JSON.
///
public protocol JSONEncodable {
    func toJSON() throws -> JSONObject
}
/// A protocol to adopt for making an object decodable from JSON.
///
public protocol JSONDecodable {
    static func decode(from content: JSONObject) throws -> Self
}
/// A protocol to adopt for making an object initializable from JSON.
///
public protocol JSONInitializable: JSONDecodable {
    init(from content: JSONObject) throws
}
extension JSONDecodable where Self: JSONInitializable {
    public static func decode(from content: JSONObject) throws -> Self {
        try Self(from: content)
    }
}

public typealias JSONConvertible = JSONEncodable & JSONDecodable


//---------------
// MARK: Private
//---------------

extension JSONValue {
    
    fileprivate func boolValue(orThrow error: Error) throws -> Bool {
        switch self {
            case .bool(let bool):
                return bool
            case .number(let double):
                switch double {
                    case 0: return false
                    case 1: return true
                    default: throw error
                }
            default: throw error
        }
    }
    
    fileprivate func intValue(orThrow error: Error) throws -> Int {
        switch self {
            case .bool(let bool):
                return bool ? 1 : 0
            case .number(let double):
                guard !double.hasFractionalPart else {
                    throw error
                }
                return Int(double)
            default: throw error
        }
    }
    
    fileprivate func doubleValue(orThrow error: Error) throws -> Double {
        switch self {
            case .bool(let bool):
                return bool ? 1.0 : 0.0
            case .number(let double):
                return double
            default: throw error
        }
    }
    
    fileprivate func stringValue(orThrow error: Error) throws -> String {
        switch self {
            case .string(let string):
                return string
            default: throw error
        }
    }
    
    fileprivate func arrayValue(orThrow error: Error) throws -> [JSONValue] {
        switch self {
            case .array(let array):
                return array
            default: throw error
        }
    }
    
    fileprivate func objectValue(orThrow error: Error) throws -> JSONObject {
        switch self {
            case .object(let object):
                return object
            default: throw error
        }
    }
}
