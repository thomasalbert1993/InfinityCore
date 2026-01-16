//
//  UIColor.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 16/01/2026.
//

#if canImport(UIKit)
import UIKit

extension UIColor {
    
    
    //------------------------------------
    // MARK: Components & Representations
    //------------------------------------
    
    /// The red/green/blue/alpha components.
    public var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// The 24-bit hexadecimal representation of the color.
    public var hexString: String? {
        guard let components = cgColor.components, components.count > 2 else {
            return nil
        }
        let r: CGFloat = components[0]
        let g: CGFloat = components[1]
        let b: CGFloat = components[2]
        return String(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255))).uppercased()
    }
    
    
    //--------------------
    // MARK: Initializers
    //--------------------
    
    /// Creates an `UIColor` from 8-bit RGBA components.
    ///
    /// - Parameter r: The 8-bit red value (0...255).
    /// - Parameter g: The 8-bit green value (0...255).
    /// - Parameter b: The 8-bit blue value (0...255).
    /// - Parameter a: The 8-bit alpha value (0...255).
    public convenience init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /// Creates an `UIColor` from 8-bit gray component.
    ///
    /// - Parameter gray: The 8-bit grayscale value (0...255).
    public convenience init(gray: Int) {
        self.init(white: CGFloat(gray) / 255, alpha: 1)
    }
    
    /// Creates an `UIColor` from a 24-bit hex value.
    ///
    /// - Parameter hex: The 24-bit RGB value (example: `0x1100F2`).
    public convenience init(hex: Int) {
        self.init(r: (hex & 0xff0000) >> 16, g: (hex & 0x00ff00) >> 8, b: (hex & 0x0000ff))
    }
    
    /// Creates an `UIColor` from a 24-bit hex `String` value.
    ///
    /// - Parameter hexString: The 24-bit RGB hexadecimal value (exemple: `1100F2`).
    public convenience init?(hexString: String) {
        let hexSet = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        guard hexString.count == 6, hexString.unicodeScalars.allSatisfy(hexSet.contains) else {
            return nil
        }
        var colorHex: UInt64 = 0
        let scanner = Scanner(string: hexString.uppercased())
        scanner.scanHexInt64(&colorHex)
        self.init(hex: Int(colorHex))
    }
    
    /// Creates an `UIColor` interpolated from a given gradient position.
    ///
    /// - Parameter colors: The gradient colors.
    /// - Parameter cursor: The gradient position (0...1).
    ///
    /// - Note: Returns `.clear` when `colors` is empty.
    public convenience init(interpolatedFrom colors: [UIColor], at cursor: Double) {
        
        guard !colors.isEmpty else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            return
        }
        
        let clampedCursor = max(0.0, min(cursor, 1.0))
        
        let segmentCount = Double(colors.count - 1)
        
        let fromIndex = Int(clampedCursor * segmentCount)
        let toIndex = min(fromIndex + 1, colors.count - 1)
        
        let localPosition = (clampedCursor * segmentCount) - Double(fromIndex)
        
        let fromComponents = colors[fromIndex].components
        let toComponents = colors[toIndex].components
        
        let red = fromComponents.red + (toComponents.red - fromComponents.red) * CGFloat(localPosition)
        let green = fromComponents.green + (toComponents.green - fromComponents.green) * CGFloat(localPosition)
        let blue = fromComponents.blue + (toComponents.blue - fromComponents.blue) * CGFloat(localPosition)
        let alpha = fromComponents.alpha + (toComponents.alpha - fromComponents.alpha) * CGFloat(localPosition)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
