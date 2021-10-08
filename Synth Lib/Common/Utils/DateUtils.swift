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
}
