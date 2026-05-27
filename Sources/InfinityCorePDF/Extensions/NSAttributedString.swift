//
//  AttributedString.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 27/05/2026.
//

#if canImport(UIKit)

import Foundation
import UIKit

extension AttributedString {
    
    public init(string: String, font: UIFont, color: UIColor = .black, underlined: Bool = false) {
        
        if underlined { // we use a NSAttributedString because .underlineStyle of AttributedString does not work
            self.init(NSAttributedString(string: string, attributes: [
                .font: font,
                .foregroundColor: color,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]))
        }
        else {
            self.init(string)
            self.font = font
            self.foregroundColor = color
        }
    }
}

#endif
