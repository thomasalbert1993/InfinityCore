//----------------------------------------------------
//  UIView.swift
//
//  Created by Thomas ALBERT on 03/03/2023.
//  All rights reserved.
//----------------------------------------------------

#if canImport(UIKit)
import UIKit

extension UIView {
    
    
    //--------------
    // MARK: Layout
    //--------------
    
    /// The view horizontal origin.
    public var originX: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    /// The view vertical origin.
    public var originY: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    /// The view horizontal center.
    public var centerX: CGFloat {
        get { center.x }
        set { center = CGPoint(x: newValue, y: center.y) }
    }

    /// The view vertical center.
    public var centerY: CGFloat {
        get { center.y }
        set { center = CGPoint(x: center.x, y: newValue) }
    }
    
    /// The view max horizontal position.
    public var maxX: CGFloat {
        get { frame.maxX }
        set { frame.origin.x = newValue - frame.size.width }
    }
    
    /// The view max vertical position.
    public var maxY: CGFloat {
        get { frame.maxY }
        set { frame.origin.y = newValue - frame.size.height }
    }

    /// The view width.
    public var sizeWidth: CGFloat {
        get { frame.size.width }
        set { frame.size.width = newValue }
    }
    
    /// The view height.
    public var sizeHeight: CGFloat {
        get { frame.size.height }
        set { frame.size.height = newValue }
    }
    
    
    //----------------
    // MARK: Subviews
    //----------------
    
    /// Removing all subviews
    public func clearSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    
    //-----------------------
    // MARK: View Controller
    //-----------------------
    
    /// The first parent `UIViewController`.
    public var parentViewController: UIViewController? {
        var parentResponder = next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
    
    
    //-----------------
    // MARK: Snapshots
    //-----------------
    
    /// Generates a snapshot of the view.
    ///
    /// - Returns: The view snapshot as `UIImage`.
    public func snapshot() -> UIImage? {
        layoutIfNeeded()
        return UIGraphicsImageRenderer(size: bounds.size).image { context in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}

#endif
