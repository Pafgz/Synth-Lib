//
//  Preset.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 30/09/2021.
//

import Foundation
import UIKit

struct Preset: Identifiable {
    var id: String
    var name: String
    var hasDemo: Bool = false
    var tagList: [Tag] = []
}
