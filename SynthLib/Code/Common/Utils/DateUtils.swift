//
//  DateUtils.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 28/09/2021.
//

import Foundation

extension Date {
    
    private static let DateFormat = "dd-MM-YY_'at'_HH:mm:ss"
    
    var currentTimeMillis: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    /**
     Formats a Date
     
     - parameters format: (String) for eg dd-MM-yyyy hh-mm-ss
     */
    func format(format: String = DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: self)
        if let newDate = dateFormatter.date(from: dateString) {
            return newDate
        } else {
            return self
        }
    }
    
    func toString(dateFormat format : String = DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
