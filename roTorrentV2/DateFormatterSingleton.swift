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
    
    var dateFormatter: NSDateFormatter
    
    private init() {
        dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    }
    
    func stringFromDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    func dateFromString(string: String) -> NSDate? {
        return dateFormatter.dateFromString(string)
    }
    
    func dateFromInt(int: Int) -> NSDate? {
        return dateFormatter.dateFromString(String(int))
    }
}

class ShortFormatterSingleton {
    static let sharedInstance = ShortFormatterSingleton()
    
    var dateFormatter: NSDateFormatter
    
    private init() {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
    }
    
    func stringFromDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
}