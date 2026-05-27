//
//  WeakRefTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 27/05/2026.
//

import Foundation
import Testing
@testable import InfinityCore

struct WeakRefTests {
    
    
    //----------------------------
    // MARK: Storing a weak value
    //----------------------------
    
    @Test("WeakRef stores the given object") func testStoresValue() {
        
        let object = NSObject()
        let weakRef = WeakRef(object)
        
        #expect(weakRef.value === object)
    }
    
    @Test("WeakRef value becomes nil after object is deallocated") func testValueBecomesNil() {
        
        var object: NSObject? = NSObject()
        let weakRef = WeakRef(object!)
        
        object = nil
        
        #expect(weakRef.value == nil)
    }
    
    @Test("WeakRef does not keep object alive") func testDoesNotRetain() {
        
        weak var witness: NSObject?
        let weakRef: WeakRef<NSObject>
        
        do {
            let object = NSObject()
            witness = object
            weakRef = WeakRef(object)
            
            #expect(witness != nil)
            #expect(weakRef.value != nil)
        }
        
        #expect(witness == nil)
        #expect(weakRef.value == nil)
    }
    
    @Test("WeakRef value can be reassigned") func testValueReassignment() {
        
        let objectA = NSObject()
        let objectB = NSObject()
        let weakRef = WeakRef(objectA)
        
        weakRef.value = objectB
        
        #expect(weakRef.value === objectB)
    }
    
    @Test("WeakRef value can be set to nil manually") func testValueSetToNil() {
        
        let object = NSObject()
        let weakRef = WeakRef(object)
        
        weakRef.value = nil
        
        #expect(weakRef.value == nil)
    }
    
    
    //----------------------------
    // MARK: Usage in collections
    //----------------------------
    
    @Test("WeakRef can be stored in an array") func testStoredInArray() {
        
        var object: NSObject? = NSObject()
        let array = [WeakRef(object!)]
        
        #expect(array.first?.value != nil)
        
        object = nil
        
        #expect(array.first?.value == nil)
    }
    
    @Test("Multiple WeakRefs to the same object all become nil") func testMultipleRefsToSameObject() {
        
        var object: NSObject? = NSObject()
        let ref1 = WeakRef(object!)
        let ref2 = WeakRef(object!)
        
        object = nil
        
        #expect(ref1.value == nil)
        #expect(ref2.value == nil)
    }
}
