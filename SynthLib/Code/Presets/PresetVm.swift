//
//  PresetVm.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import Foundation
import UIKit
import Combine
import NotificationCenter

public class PresetVm : ObservableObject {
    
    private var dbManager: CoreDataManager?
    
    private var cancellable: AnyCancellable?
    
    @Published var presets = [Preset]()
    
    @Published var selectedPreset: Preset = Preset(id: UUID(), name: "Unamed Preset")
    
    func setup(coreDataManager: CoreDataManager) {
        dbManager = coreDataManager
        if let dbManager = dbManager {
            cancellable = dbManager.$presetList.sink { values in
                self.presets = values.compactMap { entity in
                    entity.asPreset
                }
            }
        }
    }
    
    func updateNewPresetName(name: String) {
        selectedPreset = Preset(id: UUID(), name: name)
        print("New name: " + selectedPreset.name)
    }
    
    private var presetUpdateListener: [AnyCancellable] = []
}
