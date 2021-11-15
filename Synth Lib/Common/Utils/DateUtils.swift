//
//  DateUtils.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 28/09/2021.
//

import Foundation

extension Date {
    var currentTimeMillis: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
     /**
      Formats a Date

      - parameters format: (String) for eg dd-MM-yyyy hh-mm-ss
      */
     func format(format:String = "dd-MM-yyyy hh-mm-ss") -> Date {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = format
         let dateString = dateFormatter.string(from: self)
         if let newDate = dateFormatter.date(from: dateString) {
             return newDate
         } else {
             return self
         }
     }
}
