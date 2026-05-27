//
//  CoreGraphicsTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 16/01/2026.
//

import Foundation
import Testing
@testable import InfinityCoreUI

struct CoreGraphicsTests {
    
    
    //---------------------
    // MARK: CGRect Points
    //---------------------
    
    @Test("CGRect center") func rectCenter() {
        
        let rect = CGRect(x: 10, y: 20, width: 40, height: 60)
        #expect(rect.center == CGPoint(x: 30, y: 50))
    }
    
    @Test("CGRect corners") func rectCorners() {
        
        let rect = CGRect(x: 10, y: 20, width: 40, height: 60)
        
        #expect(rect.topLeft == CGPoint(x: 10, y: 20))
        #expect(rect.topRight == CGPoint(x: 50, y: 20))
        #expect(rect.bottomLeft == CGPoint(x: 10, y: 80))
        #expect(rect.bottomRight == CGPoint(x: 50, y: 80))
    }
    
    
    //---------------------
    // MARK: CGRect Offset
    //---------------------
    
    @Test("CGRect offset by vector") func rectOffsetByVector() {
        
        let rect = CGRect(x: 10, y: 20, width: 30, height: 40)
        let vector = CGVector(dx: 5, dy: -10)
        
        let offsetRect = rect.offsetBy(vector: vector)
        
        #expect(offsetRect.origin == CGPoint(x: 15, y: 10))
        #expect(offsetRect.size == rect.size)
    }
    
    
    //-----------------------
    // MARK: CGRect Cropping
    //-----------------------
    
    @Test("CGRect topRect") func rectTopRect() {
        
        let rect = CGRect(x: 0, y: 0, width: 100, height: 200)
        
        let top = rect.topRect(height: 50)
        
        #expect(top.origin == CGPoint(x: 0, y: 0))
        #expect(top.size == CGSize(width: 100, height: 50))
    }
    
    @Test("CGRect bottomRect") func rectBottomRect() {
        
        let rect = CGRect(x: 0, y: 0, width: 100, height: 200)
        
        let bottom = rect.bottomRect(height: 50)
        
        #expect(bottom.origin == CGPoint(x: 0, y: 150))
        #expect(bottom.size == CGSize(width: 100, height: 50))
    }
    
    
    //-------------------------------
    // MARK: CGPoint Vector Addition
    //-------------------------------
    
    @Test("CGPoint add vector mutating") func pointAddVector() {
        
        var point = CGPoint(x: 10, y: 20)
        point.add(vector: CGVector(dx: 5, dy: -3))
        
        #expect(point == CGPoint(x: 15, y: 17))
    }
    
    @Test("CGPoint adding vector non-mutating") func pointAddingVector() {
        
        let point = CGPoint(x: 10, y: 20)
        let result = point.adding(vector: CGVector(dx: -5, dy: 10))
        
        #expect(result == CGPoint(x: 5, y: 30))
    }
    
    
    //------------------------------
    // MARK: CGPoint Multiplication
    //------------------------------
    
    @Test("CGPoint multiply mutating") func pointMultiply() {
        
        var point = CGPoint(x: 3, y: 4)
        point.multiply(by: 2)
        
        #expect(point == CGPoint(x: 6, y: 8))
    }
    
    @Test("CGPoint multiplied non-mutating") func pointMultiplied() {
        
        let point = CGPoint(x: -2, y: 5)
        let result = point.multiplied(by: 3)
        
        #expect(result == CGPoint(x: -6, y: 15))
    }
}
