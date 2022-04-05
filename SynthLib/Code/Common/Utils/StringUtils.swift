//
//  StringUtils.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 28/09/2021.
//

import Foundation

extension String {
    
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
