//
//  Base62Tests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 08/01/2026.
//

import Foundation
import Testing
@testable import InfinityCore

struct Base62Tests {
    
    //----------------------------------
    // MARK: Data.base62EncodedString()
    //----------------------------------
    
    @Test("Test empty data encodes to empty string") func emptyDataEncodesToEmptyString() {
        
        let data = Data()
        let encoded = data.base62EncodedString()
        
        #expect(encoded == "")
    }
    
    @Test("Test single byte encodes correctly") func singleByteEncodesCorrectly() {
        
        let data = Data([0x01])
        let encoded = data.base62EncodedString()
        
        #expect(encoded == "1")
    }
    
    @Test("Test deterministic encoding for same data") func deterministicEncodingForSameData() {
        
        let data = Data([0xDE, 0xAD, 0xBE, 0xEF])
        
        let first = data.base62EncodedString()
        let second = data.base62EncodedString()
        
        #expect(first == second)
    }
    
    @Test("Test Base62 encoding uses only valid characters") func base62EncodingUsesOnlyValidCharacters() {
        
        let data = Data([0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA])
        let encoded = data.base62EncodedString()
        
        assertIsValidBase62(encoded)
    }
    
    //------------------------------------
    // MARK: String.base62EncodedString()
    //------------------------------------
    
    @Test("Test string encoding is non empty") func stringEncodingIsNonEmpty() {
        let encoded = "hello".base62Encoded()
        
        #expect(!encoded.isEmpty)
    }
    
    @Test("Test same string encodes deterministically") func sameStringEncodesDeterministically() {
        let encoded1 = "Crewmate".base62Encoded()
        let encoded2 = "Crewmate".base62Encoded()
        
        #expect(encoded1 == encoded2)
    }
    
    @Test("Test string encoding uses only Base62 characters") func stringEncodingUsesOnlyBase62Characters() {
        let encoded = "Hello, world! 🚀".base62Encoded()
        
        assertIsValidBase62(encoded)
    }
    
    //----------------------------------
    // MARK: UUID.base62EncodedString()
    //----------------------------------
    
    @Test("Test UUID Base62 encoding is stable for same UUID") func uuidBase62EncodingIsStableForSameUUID() {
        let uuid = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        
        let encoded1 = uuid.base62Encoded()
        let encoded2 = uuid.base62Encoded()
        
        #expect(encoded1 == encoded2)
    }
    
    @Test("Test UUID Base62 encoding is non empty") func uuidBase62EncodingIsNonEmpty() {
        let uuid = UUID()
        let encoded = uuid.base62Encoded()
        
        #expect(!encoded.isEmpty)
    }
    
    @Test("Test UUID Base62 encoding uses only valid characters") func uuidBase62EncodingUsesOnlyValidCharacters() {
        let uuid = UUID()
        let encoded = uuid.base62Encoded()
        
        assertIsValidBase62(encoded)
    }
    
    //---------------
    // MARK: Helpers
    //---------------
    
    private let base62Charset = CharacterSet(
        charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    )
    
    private func assertIsValidBase62(_ string: String) {
        #expect(string.unicodeScalars.allSatisfy { base62Charset.contains($0) }, "String contains characters outside Base62 alphabet")
    }
}
