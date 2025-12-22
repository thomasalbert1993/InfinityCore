import Foundation
import Testing
@testable import CrewmateCore

struct JSONTests {
    
    
    //--------------
    // MARK: Basics
    //--------------
    
    @Test("Test null equality") func testNullEquality() {
        
        #expect(JSONValue.null == .null)
    }
    
    @Test("Test primitive values") func testPrimitiveValues() throws {
        
        let bool = JSONValue.bool(true)
        let one = JSONValue.number(1)
        let number = JSONValue.number(42)
        let string = JSONValue.string("hello")
        
        #expect(try bool.boolValue == true)
        #expect(try bool.intValue == 1)
        #expect(try bool.doubleValue == 1)
        #expect(try one.boolValue == true)
        #expect(try number.intValue == 42)
        #expect(try number.doubleValue == 42)
        #expect(try string.stringValue == "hello")
    }
    
    @Test("Test array and object construction") func testArrayAndObject() throws {
        
        let array: JSONValue = .array([
            .number(1),
            .number(2)],
        )
        
        let object: JSONValue = .object([
            "a": .number(1),
            "b": .bool(false),
        ])
        
        #expect(try array.arrayValue.count == 2)
        #expect(try object.objectValue["a"]?.intValue == 1)
        #expect(try object.objectValue["b"]?.boolValue == false)
    }
    
    
    //------------------------
    // MARK: Optional Helpers
    //------------------------
    
    @Test("Test optional wrapping") func testOptionalWrapping() {
        
        #expect(JSONValue.optional(nil) == .null)
        #expect(JSONValue.optional(.string("x")) == .string("x"))

        #expect(JSONValue.optionalBool(nil) == .null)
        #expect(JSONValue.optionalBool(true) == .bool(true))

        #expect(JSONValue.optionalNumber(nil) == .null)
        #expect(JSONValue.optionalNumber(3.14) == .number(3.14))
        
        #expect(JSONValue.optionalString(nil) == .null)
        #expect(JSONValue.optionalString("Hello") == .string("Hello"))
        
        #expect(JSONValue.optionalArray(nil) == .null)
        #expect(JSONValue.optionalArray([.string("Hello")]) == .array([.string("Hello")]))
        
        #expect(JSONValue.optionalObject(nil) == .null)
        #expect(JSONValue.optionalObject(["message": .string("Hello")]) == .object(["message": .string("Hello")]))
    }
    
    @Test("Test when(condition)") func testWhenCondition() {
        
        let value = JSONValue.string("ok")

        #expect(value.when(true) == value)
        #expect(value.when(false) == .null)
    }
    
    @Test("Test nullAsNil") func testNullAsNil() {
        
        #expect(JSONValue.null.nullAsNil == nil)
        #expect(JSONValue.string("x").nullAsNil != nil)
    }
    
    
    //-----------------------
    // MARK: Typed Accessors
    //-----------------------
    
    @Test("Test bool accessor accepts numbers 0 and 1") func testBoolFromNumber() throws {
        
        #expect(try JSONValue.number(1).boolValue == true)
        #expect(try JSONValue.number(0).boolValue == false)
    }
    
    @Test("Test invalid typed access throws") func testInvalidAccessThrows() {
        
        let value = JSONValue.string("oops")
        
        #expect(throws: Error.self) {
            _ = try value.boolValue
        }
        
        #expect(throws: Error.self) {
            _ = try value.intValue
        }
        
        #expect(throws: Error.self) {
            _ = try value.doubleValue
        }

        #expect(throws: Error.self) {
            _ = try value.arrayValue
        }
        
        #expect(throws: Error.self) {
            _ = try value.objectValue
        }
    }

    @Test("Test Int accessor only accepts non-fractional numbers") func testIntOnlyNonFractional() throws {
        
        #expect(try JSONValue.number(10).intValue == 10)

        #expect(throws: Error.self) {
            _ = try JSONValue.number(3.14).intValue
        }
    }
    
    
    //----------------
    // MARK: Equality
    //----------------
    
    @Test("Test default equality respects order") func testDrrayOrderMatters() {
        
        let a: JSONValue = .array([.number(1), .number(2)])
        let b: JSONValue = .array([.number(2), .number(1)])
        
        #expect(a != b)
        #expect(!a.isEqual(to: b))
    }
    
    @Test("Test array set equality ignores order and duplicates") func testArrayAsSetEquality() {
        
        let a: JSONValue = .array([.number(1), .number(2), .number(2)])
        let b: JSONValue = .array([.number(2), .number(1)])
        
        #expect(a != b)
        #expect(a.isEqual(to: b, handleArraysAsSets: true))
    }

    @Test("Test nested equality") func testNestedEquality() {
        
        let a: JSONValue = .object([
            "items": .array([ .number(1), .number(2) ])
        ])
        
        let b: JSONValue = .object([
            "items": .array([ .number(2), .number(1) ])
        ])
        
        #expect(a != b)
        #expect(a.isEqual(to: b, handleArraysAsSets: true))
    }
    
    
    //------------------------
    // MARK: RawRepresentable
    //------------------------
    
    @Test("Test JSONValue raw representable primitives") func testJSONValueRawRepresentablePrimitives() {
        
        #expect(JSONValue(rawValue: NSNull()) == .null)
        #expect(JSONValue(rawValue: true) == .bool(true))
        #expect(JSONValue(rawValue: false) == .bool(false))
        #expect(JSONValue(rawValue: 0) == .number(0))
        #expect(JSONValue(rawValue: 1) == .number(1))
        #expect(JSONValue(rawValue: 3.14) == .number(3.14))
        #expect(JSONValue(rawValue: "hello") == .string("hello"))
    }
    
    @Test("Test JSONValue raw representable round trip") func testJSONValueRawRepresentableRoundTrip() {
        
        let original: JSONValue = .object([
            "a": .number(1),
            "b": .array([ .bool(true), .null ]),
        ])
        
        let raw = original.rawValue
        let restored = JSONValue(rawValue: raw)
        
        #expect(restored == original)
    }

    @Test("Test JSONObject raw representable round trip") func testJSONObjectRawRepresentableRoundTrip() {
        
        let object: JSONObject = [
            "x": .string("y"),
            "n": .null,
        ]
        
        let raw = object.rawValue
        let restored = JSONObject(rawValue: raw)
        
        #expect(restored == object)
    }
    
    
    //----------------------------
    // MARK: JSONValueConvertible
    //----------------------------
    
    @Test("Test primitive conversion") func testPrimitiveConversion() {
        
        #expect(NSNull().jsonValue == .null)
        #expect(true.jsonValue == .bool(true))
        #expect(5.jsonValue == .number(5))
        #expect(3.14.jsonValue == .number(3.14))
        #expect("hi".jsonValue == .string("hi"))
    }
    
    @Test("Test array conversion") func testArrayConversion() {

        let value: JSONValue = ["a", "b", "c"].jsonValue
        
        #expect(value == .array([
            .string("a"),
            .string("b"),
            .string("c"),
        ]))
    }
    
    @Test("Test dictionary conversion") func testDictionaryConversion() {
        
        let value: JSONValue = [
            "a": "hello",
            "b": "world",
        ].jsonValue
        
        #expect(value == .object([
            "a": .string("hello"),
            "b": .string("world"),
        ]))
    }
    
    @Test("Test convertible equality helper") func testConvertibleEquality() {
        
        let lhs: JSONValueConvertible = ["a": 1, "b": 2]
        let rhs: JSONValueConvertible = ["b": 2, "a": 1]
        
        #expect(lhs.isEqual(to: rhs))
    }
    
    
    //-----------------------------------------
    // MARK: JSONObject Convenient Initializer
    //-----------------------------------------
    
    @Test("Test nil values become null") func testNilBecomesNull() {
        
        let object = JSONObject([
            "a": 1,
            "b": nil,
            "c": "x",
        ])
        
        #expect(object["a"] == .number(1))
        #expect(object["b"] == .null)
        #expect(object["c"] == .string("x"))
    }
    
    
    //---------------
    // MARK: Codable
    //---------------
    
    @Test("Test encoding decoding null") func testEncodingDecodingNull() throws {
        
        let value: JSONValue = .null
        #expect(try roundTripUsingEncoder(value) == value)
    }
    
    @Test("Test encoding decoding bool") func testEncodingDecodingBool() throws {
        
        let value1: JSONValue = .bool(true)
        #expect(try roundTripUsingEncoder(value1) == value1)
        
        let value2: JSONValue = .bool(false)
        #expect(try roundTripUsingEncoder(value2) == value2)
    }
    
    @Test("Test encoding decoding number") func testEncodingDecodingNumber() throws {
        
        let value1: JSONValue = .number(1)
        #expect(try roundTripUsingEncoder(value1) == value1)
        
        let value2: JSONValue = .number(3.14)
        #expect(try roundTripUsingEncoder(value2) == value2)
    }
    
    @Test("Test encoding decoding string") func testEncodingDecodingString() throws {
        
        let value: JSONValue = .string("hello")
        #expect(try roundTripUsingEncoder(value) == value)
    }
    
    @Test("Test encoding decoding array") func testEncodingDecodingArray() throws {
        
        let value: JSONValue = .array([
            .number(1),
            .string("two"),
            .bool(false),
            .null,
        ])
        
        #expect(try roundTripUsingEncoder(value) == value)
    }
    
    @Test("Test encoding decoding object") func testEncodingDecodingObject() throws {
        
        let value: JSONValue = .object([
            "id": .number(123),
            "name": .string("Alice"),
            "active": .bool(true),
        ])
        
        #expect(try roundTripUsingEncoder(value) == value)
    }
    
    @Test("Test encoding decoding nested values") func testEncodingDecodingNestedValues() throws {
        
        let value: JSONValue = .object([
            "user": .object([
                "id": .number(1),
                "tags": .array([
                    .string("swift"),
                    .string("coredata")
                ])
            ]),
            "valid": .bool(true)
        ])
        
        #expect(try roundTripUsingEncoder(value) == value)
    }
    
    @Test("Test decoding raw JSON data") func testDecodingRawJSONData() throws {
        
        let json = """
        {
            "id": 1,
            "name": "Bob",
            "scores": [10, 20, 30],
            "active": true,
            "meta": null
        }
        """.data(using: .utf8)!

        let expectedValue: JSONValue = .object([
            "id": .number(1),
            "name": .string("Bob"),
            "scores": .array([.number(10), .number(20), .number(30)]),
            "active": .bool(true),
            "meta": .null
        ])
        
        let value = try decoder.decode(JSONValue.self, from: json)
        #expect(value == expectedValue)
    }
    
    
    //--------------
    // MARK: Helper
    //--------------
    
    private func roundTripUsingEncoder(_ value: JSONValue) throws -> JSONValue {
        let data = try encoder.encode(value)
        return try decoder.decode(JSONValue.self, from: data)
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
}
