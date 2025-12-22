//
//  AESEncryptionTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct AESEncryptionTests {
    
    @Test("Test AES encrypt/decrypt round trip with all key sizes") func testAESEncryptDecryptRoundTripWillAllKeySizes() {
        
        let keys = [
            TestData.key128,
            TestData.key192,
            TestData.key256,
        ]
        
        for key in keys {
            
            let encrypted = AESEncryption.encrypt(data: TestData.plaintext, key: key, iv: TestData.iv)
            #expect(encrypted != nil)
            
            let decrypted = AESEncryption.decrypt(data: encrypted!, key: key, iv: TestData.iv)
            #expect(decrypted == TestData.plaintext)
        }
    }
    
    @Test("Test same input, key and IV produce same ciphertext") func testDeterministicWithFixedIV() {
        
        let encrypted1 = AESEncryption.encrypt(data: TestData.plaintext, key: TestData.key256, iv: TestData.iv)
        let encrypted2 = AESEncryption.encrypt(data: TestData.plaintext, key: TestData.key256, iv: TestData.iv)
        
        #expect(encrypted1 == encrypted2)
    }
    
    @Test("Test different IV produces different ciphertext") func testDifferentIVChangesCiphertext() {
        
        let iv1 = Data(repeating: 0x00, count: AESEncryption.ivLength)
        let iv2 = Data(repeating: 0xFF, count: AESEncryption.ivLength)
        
        let encrypted1 = AESEncryption.encrypt(data: TestData.plaintext, key: TestData.key256, iv: iv1)
        let encrypted2 = AESEncryption.encrypt(data: TestData.plaintext, key: TestData.key256, iv: iv2)
        
        #expect(encrypted1 != encrypted2)
    }
    
    @Test("Test invalid key length is rejected") func testInvalidKeyLength() {
        
        let invalidKey = Data(repeating: 0xFF, count: 64) // invalid

        let encrypted = AESEncryption.encrypt(data: TestData.plaintext, key: invalidKey, iv: TestData.iv )

        #expect(encrypted == nil)
    }
    
    @Test("Test decrypting with wrong key fails") func testWrongKeyFails() {
        
        let encrypted = AESEncryption.encrypt(data: TestData.plaintext, key: TestData.key256, iv: TestData.iv)!
        let decrypted = AESEncryption.decrypt(data: encrypted, key: TestData.key128, iv: TestData.iv) // wrong key
        
        #expect(decrypted != TestData.plaintext)
    }
    
    @Test("Test decrypting with wrong IV fails") func testWrongIVFails() {
        
        let encrypted = AESEncryption.encrypt(data: TestData.plaintext, key: TestData.key256, iv: TestData.iv )!
        
        let wrongIV = Data(repeating: 0xAB, count: AESEncryption.ivLength)
        let decrypted = AESEncryption.decrypt(data: encrypted, key: TestData.key256, iv: wrongIV)
        
        #expect(decrypted != TestData.plaintext)
    }
    
    @Test("Test encrypting empty data works") func testEmptyDataEncryption() {
        
        let empty = Data()
        
        let encrypted = AESEncryption.encrypt(data: empty, key: TestData.key128, iv: TestData.iv)
        #expect(encrypted != nil)
        
        let decrypted = AESEncryption.decrypt(data: encrypted!, key: TestData.key128, iv: TestData.iv)
        #expect(decrypted == empty)
    }
    
    @Test("Test decrypt returns nil for too-short data") func testDecryptTooShortData() {
        
        let shortData = Data(repeating: 0x00, count: 1)
        let decrypted = AESEncryption.decrypt(data: shortData, key: TestData.key128, iv: TestData.iv)
        
        #expect(decrypted == nil)
    }
    
    @Test("Test random IV generation returns correct length") func testRandomIVGeneration() {
        
        let iv = AESEncryption.generateRandomIV()
        
        #expect(iv != nil)
        #expect(iv!.count == AESEncryption.ivLength)
    }

    @Test("Test generated IVs are random") func testRandomIVUniqueness() {
        
        let iv1 = AESEncryption.generateRandomIV()
        let iv2 = AESEncryption.generateRandomIV()
        
        #expect(iv1 != iv2)
    }
    
    
    //---------------
    // MARK: Helpers
    //---------------
    
    private enum TestData {
        
        static let key128 = Data(repeating: 0x01, count: 16)
        static let key192 = Data(repeating: 0x02, count: 24)
        static let key256 = Data(repeating: 0x03, count: 32)
        
        static let iv = Data(repeating: 0x00, count: AESEncryption.ivLength)
        
        static let plaintext = "Crewmate is magic 🪄".data(using: .utf8)!
    }
}
