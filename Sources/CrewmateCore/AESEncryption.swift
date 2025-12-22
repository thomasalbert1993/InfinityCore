//
//  AESEncryption.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation
import CommonCrypto

/// A namespace providing helper functions to perform AES encryption and decryption
/// using the **AES-CBC** mode with **PKCS7 padding**.
///
/// This utility supports AES with 128-, 192- or 256-bit keys, depending on the provided key length.
/// It also provides a helper to generate random initialization vectors (IVs).
///
/// - Important: AES-CBC requires a random, unique IV for each encryption operation.
/// Never reuse the same IV with the same key for different messages.
public enum AESEncryption {
    
    /// Encrypts the given data using **AES (CBC mode)** with PKCS7 padding.
    ///
    /// - Parameter data: The plaintext data to encrypt.
    /// - Parameter key: The AES key (can be 128, 192, or 256 bits).
    /// - Parameter iv: The initialization vector (`16` bytes required).
    ///
    /// - Returns: The encrypted data, or `nil` if the encryption fails.
    ///
    /// - Note: The key length determines AES strength:
    ///    - 16 bytes → AES-128
    ///    - 24 bytes → AES-192
    ///    - 32 bytes → AES-256
    ///
    /// - Note: The IV must be **exactly 16 bytes** long.
    public static func encrypt(data: Data, key: Data, iv: Data) -> Data? {
        guard isValidKeyLength(key.count), iv.count == ivLength else { return nil }
        return aesCrypt(data: data, operation: kCCEncrypt, key: key, iv: iv)
    }
    
    /// Decrypts data previously encrypted using **AES (CBC mode)** with PKCS7 padding.
    ///
    /// - Parameter data: The ciphertext data to decrypt.
    /// - Parameter key: The AES key (can be 128, 192, or 256 bits).
    /// - Parameter iv: The initialization vector used during encryption.
    ///
    /// - Returns: The decrypted data, or `nil` if decryption fails.
    ///
    /// - Note: The IV and key must match those used for encryption.
    public static func decrypt(data: Data, key: Data, iv: Data) -> Data? {
        guard data.count >= kCCBlockSizeAES128, isValidKeyLength(key.count), iv.count == ivLength else {
            return nil
        }
        return aesCrypt(data: data, operation: kCCDecrypt, key: key, iv: iv)
    }
    
    /// The fixed AES Initialization Vector size (in bytes).
    ///
    /// AES-CBC always uses a **16-byte** IV.
    public static let ivLength = 16
    
    /// Generates a cryptographically secure random initialization vector (IV).
    ///
    /// - Returns: A random 16-byte `Data` instance, or `nil` if generation fails.
    ///
    /// - Important: A unique IV should be used for each encryption.
    /// Store the IV alongside the ciphertext if decryption will be needed later.
    public static func generateRandomIV() -> Data? {
        var iv = [UInt8](repeating: 0, count: ivLength)
        let result = SecRandomCopyBytes(kSecRandomDefault, iv.count, &iv)
        return result == errSecSuccess ? Data(iv) : nil
    }
    
    
    //---------------
    // MARK: Private
    //---------------
    
    private static func isValidKeyLength(_ length: Int) -> Bool {
        length == 16 || length == 24 || length == 32
    }
    
    private static func aesCrypt(
        data: Data,
        operation: Int,
        algorithm: Int = kCCAlgorithmAES,
        options: Int = kCCOptionPKCS7Padding,
        key: Data,
        iv: Data)
        -> Data?
    {
        iv.withUnsafeBytes { ivUnsafeRawBufferPointer in
            key.withUnsafeBytes { keyUnsafeRawBufferPointer in
                data.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                    // Give the data out some breathing room for PKCS7's padding.
                    let dataOutSize: Int = data.count + kCCBlockSizeAES128 * 2
                    let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize, alignment: 1)
                    defer {
                        dataOut.deallocate()
                    }
                    var dataOutMoved: Int = 0
                    let status = CCCrypt(
                        CCOperation(operation),
                        CCAlgorithm(algorithm),
                        CCOptions(options),
                        keyUnsafeRawBufferPointer.baseAddress, key.count,
                        ivUnsafeRawBufferPointer.baseAddress,
                        dataInUnsafeRawBufferPointer.baseAddress, data.count,
                        dataOut, dataOutSize,
                        &dataOutMoved
                    )
                    guard status == kCCSuccess else {
                        return nil
                    }
                    return Data(bytes: dataOut, count: dataOutMoved)
                }
            }
        }
    }
}
