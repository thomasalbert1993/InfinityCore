//
//  Date.swift
//  CrewmateCore
//
//  Created by Thomas ALBERT on 20/12/2025.
//

import Foundation

extension Date {
    
    /// The equivalent date offsetted by 100 nanosecond in the past.
    /// You can use it for excluding date from closed ranges.
    public var slightlyBefore: Date {
        addingTimeInterval(-1e-7)
    }
    
    /// The equivalent date offsetted by 100 nanosecond in the future.
    /// You can use it for excluding date from closed ranges.
    public var slightlyAfter: Date {
        addingTimeInterval(1e-7)
    }
    
    /// Gets the date components (year/month/day).
    ///
    /// - Parameter includingTime: A boolean indicating wheter time components (hours/minutes/seconds) should be included.
    /// - Parameter calendar: The calendar to use.
    ///
    /// - Returns: The `DateComponents`.
    public func components(includingTime: Bool = true, in calender: Calendar = .current) -> DateComponents {
        let calendar = Calendar.current
        var components: DateComponents
        if includingTime {
            components = calendar.dateComponents([ .year, .month, .day, .hour, .minute, .second ], from: self)
        } else {
            components = calendar.dateComponents([ .year, .month, .day ], from: self)
        }
        components.calendar = calendar
        return components
    }
    
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
    public func utcString(timeStyle: TimeStyle = .second) -> String {
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
