//
//  StringTests.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 23/12/2025.
//

import Foundation
import Testing
@testable import CrewmateCore

struct StringTests {
    
    
    //----------------------------
    // MARK: Trimming Whitespaces
    //----------------------------
    
    @Test("Test trimmed removes leading and trailing whitespaces") func testTrimmedWhitespaces() {
        
        let input = "   Hello World   "
        
        #expect(input.trimmed() == "Hello World")
    }
    
    @Test("Test trimmed removes newlines and tabs") func testTrimmedNewlines() {
        
        let input = "\n\t Hello World \t\n"
        
        #expect(input.trimmed() == "Hello World")
    }

    @Test("Test trimmed does not remove inner whitespaces") func testTrimmedKeepsInnerSpaces() {
        
        let input = "  Hello   World  "
        
        #expect(input.trimmed() == "Hello   World")
    }
    
    @Test("Test trimmed on already trimmed string returns same string") func testTrimmedIdempotent() {
        
        let input = "Hello"
        
        #expect(input.trimmed() == "Hello")
    }

    @Test("Test trimmed on empty string returns empty string") func testTrimmedEmpty() {
        
        #expect("".trimmed() == "")
    }

    @Test("Test trimmed on whitespace-only string returns empty string") func testTrimmedWhitespaceOnly() {
        
        let input = " \n\t  "

        #expect(input.trimmed().isEmpty)
    }
    
    @Test("Test trimmed is idempotent") func testTrimmedIdempotency() {
        
        let input = "  Hello  "
        
        #expect(input.trimmed().trimmed() == "Hello")
    }
    
    
    //------------------------
    // MARK: Removing Accents
    //------------------------
    
    @Test("Test removingAccents removes common accents") func testRemovingAccentsBasic() {
        
        let input = "éèêëàâäîïôöùûüç"
        
        #expect(input.removingAccents() == "eeeeaaaiioouuuc")
    }
    
    @Test("Test removingAccents preserves non-accented characters") func testRemovingAccentsPreservesCharacters() {
        
        let input = "Hello World!"
        
        #expect(input.removingAccents() == "Hello World!")
    }
    
    @Test("Test removingAccents works with mixed text") func testRemovingAccentsMixed() {
        
        let input = "Crème Brûlée"
        
        #expect(input.removingAccents() == "Creme Brulee")
    }
    
    @Test("Test removingAccents works with uppercase accented characters") func testRemovingAccentsUppercase() {
        
        let input = "ÀÉÎÖÙ"
        
        #expect(input.removingAccents() == "AEIOU")
    }
    
    @Test("Test removingAccents preserves emojis and symbols") func testRemovingAccentsEmoji() {
        
        let input = "Café ☕️"
        
        #expect(input.removingAccents() == "Cafe ☕️")
    }
    
    @Test("Test removingAccents is deterministic") func testRemovingAccentsDeterministic() {
        
        let input = "àéîöù"
        
        let r1 = input.removingAccents()
        let r2 = input.removingAccents()
        
        #expect(r1 == r2)
    }
    
    
    //-------------------------
    // MARK: Converting to URL
    //-------------------------
    
    @Test("Test toURL converts valid HTTPS URL") func testValidHTTPSURL() throws {
        
        let url = try "https://example.com".toURL()
        
        #expect(url.scheme == "https")
        #expect(url.host == "example.com")
    }
    
    @Test("Test toURL converts valid HTTP URL") func testValidHTTPURL() throws {
        
        let url = try "http://localhost:8080/path".toURL()
        
        #expect(url.scheme == "http")
        #expect(url.host == "localhost")
        #expect(url.port == 8080)
        #expect(url.path == "/path")
    }
    
    @Test("Test toURL converts URL with query and fragment") func testURLWithQueryAndFragment() throws {
        
        let url = try "https://example.com/search?q=test#top".toURL()
        
        #expect(url.query == "q=test")
        #expect(url.fragment == "top")
    }
    
    @Test("Test toURL throws on empty string") func testEmptyStringThrows() {
        
        #expect(throws: Error.self) {
            _ = try "".toURL()
        }
    }
    
    @Test("Test toURL throws on malformed URL") func testMalformedURLThrows() {
        
        #expect(throws: Error.self) {
            _ = try "ht!tp:// bad url".toURL()
        }
    }

    @Test("Test toURL throws on whitespace-only string") func testWhitespaceOnlyThrows() {
        
        #expect(throws: Error.self) {
            _ = try "   ".toURL()
        }
    }
    
    @Test("Test toURL accepts file URLs") func testFileURL() throws {
        
        let url = try "file:///tmp/test.txt".toURL()
        
        #expect(url.isFileURL)
        #expect(url.path == "/tmp/test.txt")
    }
    
    @Test("Test toURL accepts custom schemes") func testCustomSchemeURL() throws {
        
        let url = try "myapp://open?id=42".toURL()
        
        #expect(url.scheme == "myapp")
        #expect(url.host == "open")
    }
}
