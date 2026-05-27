//
//  Data.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 22/12/2025.
//

import Foundation

extension Data {
    
    /// Converts data to hexadecimal `String`.
    public var hexString: String  {
        map { String(format: "%02.2hhx", $0) }.joined()
    }
}
