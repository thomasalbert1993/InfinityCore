//
//  UIScreen.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 27/05/2026.
//

#if canImport(UIKit)
import UIKit

extension UIScreen {
    
    /// The device's display corner radius.
    public var displayCornerRadius: CGFloat {
        value(forKey: "_displayCornerRadius") as? CGFloat ?? 0
    }
}

#endif
