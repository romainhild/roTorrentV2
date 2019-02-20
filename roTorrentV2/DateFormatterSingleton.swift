//
//  DateFormatterSingleton.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class DateFormatterSingleton {
    static let sharedInstance = DateFormatterSingleton()
    
    var dateFormatter: DateFormatter
    
    fileprivate init() {
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    }
    
    func stringFromDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func dateFromString(_ string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
    
    func dateFromInt(_ int: Int) -> Date? {
        return dateFormatter.date(from: String(int))
    }
}

class ShortFormatterSingleton {
    static let sharedInstance = ShortFormatterSingleton()
    
    var dateFormatter: DateFormatter
    
    fileprivate init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    func stringFromDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
