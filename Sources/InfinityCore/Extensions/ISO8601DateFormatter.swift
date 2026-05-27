//
//  ISO8601DateFormatter.swift
//  InfinityCore
//
//  Created by Thomas ALBERT on 13/01/2026.
//

import Foundation

extension ISO8601DateFormatter: @unchecked @retroactive Sendable {
    
    /// An UTC formatter for dates without time.
    public static let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [ .withFullDate ]
        return dateFormatter
    }()
    
    /// An UTC formatter for dates with time.
    public static let dateTimeFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
    
    /// An UTC formatter for dates with microsecond-precise fractional time.
    public static let dateTimeFractionalFormatter: ISO8601DateFormatter = {
        MicroSecondISO8601DateFormatter()
    }()
    
    /// Converting a given ISO8601 formatted string into a `Date`.
    ///
    /// - Parameter string: The input string.
    ///
    /// - Returns: The corresponding date.
    public static func date(from string: String) throws -> Date {
        let formatter: ISO8601DateFormatter
        
        if string.range(of: "T") != nil {
            if string.range(of: ".") != nil {
                formatter = .dateTimeFractionalFormatter
            } else {
                formatter = .dateTimeFormatter
            }
        }
        else {
            formatter = .dateFormatter
        }
        
        guard let date = formatter.date(from: string) else {
            throw "Invalid ISO8601 date '\(string)'"
        }
        return date
    }
}

/// A custom `ISO8601DateFormatter` for formatting microsecond-precise dates.
///
/// Make sure to use this formatter when you need microsecond-precise dates, as
/// default `ISO8601DateFormatter` formatter only handles millliseconds.
///
public final class MicroSecondISO8601DateFormatter: ISO8601DateFormatter, @unchecked Sendable {
    
    public override init() {
        super.init()
        
        formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func date(from string: String) -> Date? {
        
        guard let match = microsecondRegex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) else {
            return super.date(from: string) // no microseconds, parse directly
        }
        
        let nsString = string as NSString
        let baseDateString = nsString.substring(with: match.range(at: 1))
        let microsecondsString = nsString.substring(with: match.range(at: 2))
        let timeZoneString = nsString.substring(with: match.range(at: 3))
        
        let dateStringWithoutMicroseconds = baseDateString + ".000000" + timeZoneString
        guard let baseDate = super.date(from: dateStringWithoutMicroseconds) else {
            return nil
        }
        
        let paddedMicrosecondsString = microsecondsString.padding(toLength: 6, withPad: "0", startingAt: 0)
        guard let microseconds = Double("0." + paddedMicrosecondsString) else {
            return baseDate
        }
        
        return baseDate.addingTimeInterval(microseconds)
    }
    
    public override func string(from date: Date) -> String {
            
        let timeInterval = date.timeIntervalSince1970
        let wholePart = floor(timeInterval)
        let fractionalPart = timeInterval - wholePart
            
        let microseconds = Int(round(fractionalPart * 1_000_000))
            
        let baseString = super.string(from: date.timeIntervalSince1970 > 0 ? Date(timeIntervalSince1970: wholePart) : date)
        
        if baseString.contains(".") {
            return baseString.replacingOccurrences(
                of: "\\.\\d+Z",
                with: String(format: ".%06dZ", microseconds),
                options: .regularExpression
            )
        }
        else {
            return baseString.replacingOccurrences(
                of: "Z$",
                with: String(format: ".%06dZ", microseconds),
                options: .regularExpression
            )
        }
    }
    
    private let microsecondRegex = try! NSRegularExpression(pattern: #"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})\.(\d{1,6})(Z|[\+\-]\d{2}:\d{2})"#)
}
