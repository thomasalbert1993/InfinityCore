//
//  UIColorTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 16/01/2026.
//

#if canImport(UIKit)

import Foundation
import UIKit
import Testing
@testable import InfinityCoreUI

struct UIColorTests {
    
    
    //--------------------------------------
    // MARK: Components and Representations
    //--------------------------------------
    
    @Test("components returns correct RGBA values") func components() {
        
        let color = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8)
        let components = color.components
        
        #expect(components.red.isApproximatelyEqual(to: 0.2))
        #expect(components.green.isApproximatelyEqual(to: 0.4))
        #expect(components.blue.isApproximatelyEqual(to: 0.6))
        #expect(components.alpha.isApproximatelyEqual(to: 0.8))
    }
    
    @Test("hexString returns correct hex representation") func hexString() {
        
        let color = UIColor(r: 17, g: 0, b: 242)
        #expect(color.hexString == "1100F2")
    }
    
    @Test("hexString returns nil for non-RGB colors") func hexStringNonRGB() {
        
        let gray = UIColor(white: 0.5, alpha: 1.0)
        #expect(gray.hexString == nil)
    }
    
    
    //--------------------
    // MARK: Initializers
    //--------------------
    
    @Test("init(r:g:b:a:) creates correct color") func initRGBA() {
        
        let color = UIColor(r: 255, g: 128, b: 0, a: 64)
        let components = color.components
        
        #expect(components.red.isApproximatelyEqual(to: 1.0))
        #expect(components.green.isApproximatelyEqual(to: 128.0 / 255.0))
        #expect(components.blue.isApproximatelyEqual(to: 0.0))
        #expect(components.alpha.isApproximatelyEqual(to: 64.0 / 255.0))
    }
    
    @Test("init(gray:) creates grayscale color") func initGray() {
        
        let color = UIColor(gray: 128)
        let components = color.components
        
        #expect(components.red.isApproximatelyEqual(to: 128.0 / 255.0))
        #expect(components.green.isApproximatelyEqual(to: 128.0 / 255.0))
        #expect(components.blue.isApproximatelyEqual(to: 128.0 / 255.0))
        #expect(components.alpha.isApproximatelyEqual(to: 1.0))
    }
    
    @Test("init(hex:) creates correct color from int") func initHexInt() {
        
        let color = UIColor(hex: 0x1100F2)
        #expect(color.hexString == "1100F2")
    }
    
    @Test("init(hex:) succeeds with valid hex string") func initHexStringValid() {
        
        let color = UIColor(hex: "Aa00Ff")
        #expect(color?.hexString == "AA00FF")
    }
    
    @Test("init(hex:) fails with invalid length") func initHexStringInvalidLength() {
        
        #expect(UIColor(hex: "FFF") == nil)
    }
    
    @Test("init(hex:) fails with invalid characters") func initHexStringInvalidCharacters() {
        
        #expect(UIColor(hex: "ZZ00FF") == nil)
    }
    
    
    //------------------------------
    // MARK: Gradient Interpolation
    //------------------------------
    
    @Test("Interpolated color at bounds") func interpolationBounds() {
        
        let colors: [UIColor] = [.red, .blue]
        
        let start = UIColor(interpolatedFrom: colors, at: 0.0)
        let end = UIColor(interpolatedFrom: colors, at: 1.0)
        
        #expect(start.hexString == UIColor.red.hexString)
        #expect(end.hexString == UIColor.blue.hexString)
    }
    
    @Test("Interpolated color at midpoint") func interpolationMidpoint() {
        
        let colors: [UIColor] = [.red, .blue]
        let mid = UIColor(interpolatedFrom: colors, at: 0.5)
        let c = mid.components
        
        #expect(c.red.isApproximatelyEqual(to: 0.5))
        #expect(c.green.isApproximatelyEqual(to: 0.0))
        #expect(c.blue.isApproximatelyEqual(to: 0.5))
        #expect(c.alpha.isApproximatelyEqual(to: 1.0))
    }
    
    @Test("Interpolated color with empty array returns clear") func interpolationEmpty() {
        
        let color = UIColor(interpolatedFrom: [], at: 0.5)
        let c = color.components
        
        #expect(c.alpha == 0)
    }
}

private extension CGFloat {
    
    func isApproximatelyEqual(to other: CGFloat, tolerance: CGFloat = 0.0001) -> Bool {
        abs(self - other) <= tolerance
    }
}

#endif
