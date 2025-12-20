//
//  Date.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 20/12/2025.
//

import Foundation

extension Date {
    
    public enum TimeStyle {
        case none
        case second
        case microsecond
    }
    
    /// Converts date to `ISO8601` UTC string.
    ///
    /// - Parameter timeStyle: The time style (ie. `none`, `second` or `microsecond`).
    ///
    /// - Returns: The serialized date.
    public func toUTCString(timeStyle: TimeStyle = .second) -> String {
        switch timeStyle {
            case .none:
                return ISO8601DateFormatter.dateFormatter.string(from: self)
            case .second:
                return ISO8601DateFormatter.dateTimeFormatter.string(from: self)
            case .microsecond:
                return ISO8601DateFormatter.dateTimeFractionalFormatter.string(from: self)
        }

    }
}
