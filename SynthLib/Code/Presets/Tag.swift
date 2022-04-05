//
//  Tag.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 04/10/2021.
//

import Foundation

struct Tag: Identifiable {
    var id: UUID = UUID()
    var name: String
    var presetList: [Preset] = []
}
