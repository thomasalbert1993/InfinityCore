//
//  UIViewTests.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 18/01/2026.
//

#if canImport(UIKit)

import Foundation
import UIKit
import Testing
@testable import InfinityCoreUI

@MainActor
struct UIViewTests {
    
    
    //--------------------------------------------
    // MARK: Frame Convenient Getters and Setters
    //--------------------------------------------
    
    @Test("originX / originY getters & setters") func testOrigin() {
        
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 100, height: 50))
        
        #expect(view.originX == 10)
        #expect(view.originY == 20)
        
        view.originX = 42
        view.originY = 84
        
        #expect(view.frame.origin.x == 42)
        #expect(view.frame.origin.y == 84)
    }
    
    @Test("centerX / centerY getters & setters") func testCenter() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        #expect(view.centerX == 50)
        #expect(view.centerY == 50)
        
        view.centerX = 200
        view.centerY = 300
        
        #expect(view.center.x == 200)
        #expect(view.center.y == 300)
    }
    
    @Test("maxX / maxY getters & setters") func testMaxValues() {
        
        let view = UIView(frame: CGRect(x: 10, y: 20, width: 100, height: 50))
        
        #expect(view.maxX == 110)
        #expect(view.maxY == 70)
        
        view.maxX = 200
        view.maxY = 300
        
        #expect(view.frame.origin.x == 100) // 200 - 100
        #expect(view.frame.origin.y == 250) // 300 - 50
    }
    
    @Test("sizeWidth / sizeHeight getters & setters") func testSize() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 80))
        
        #expect(view.sizeWidth == 50)
        #expect(view.sizeHeight == 80)
        
        view.sizeWidth = 200
        view.sizeHeight = 400
        
        #expect(view.frame.size.width == 200)
        #expect(view.frame.size.height == 400)
    }
    
    
    //------------------------------
    // MARK: UIView.clearSubviews()
    //------------------------------
    
    @Test("clearSubviews removes all subviews") func testClearSubviews() {
        
        let parent = UIView()
        let child1 = UIView()
        let child2 = UIView()
        
        parent.addSubview(child1)
        parent.addSubview(child2)
        
        #expect(parent.subviews.count == 2)
        
        parent.clearSubviews()
        
        #expect(parent.subviews.isEmpty)
        #expect(child1.superview == nil)
        #expect(child2.superview == nil)
    }
    
    
    //-----------------------------------
    // MARK: UIView.parentViewController
    //-----------------------------------
    
    @Test("parentViewController finds first UIViewController") func testParentViewController() {
        
        let viewController = UIViewController()
        let containerView = UIView()
        let childView = UIView()
        
        viewController.view.addSubview(containerView)
        containerView.addSubview(childView)
        
        #expect(childView.parentViewController === viewController)
    }
    
    @Test("parentViewController returns nil when not attached") func testParentViewControllerNil() {
        
        let view = UIView()
        #expect(view.parentViewController == nil)
    }
    
    
    //-------------------------
    // MARK: UIView.snapshot()
    //-------------------------
    
    @Test("snapshot() returns a non-nil image with correct dimensions") func testSnapshot() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .red
        
        let image = view.snapshot()
        
        #expect(image != nil)
        #expect(image?.size == CGSize(width: 100, height: 100))
    }
}

#endif
