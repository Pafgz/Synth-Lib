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

final class PresetVm : ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var presets = [Preset]()
    
    @Published var selectedPreset: Preset = Preset(id: UUID(), name: "Unamed Preset")
    
    init() {
        CoreDataManager.shared.$presetList
            .sink { values in
                self.presets = values.compactMap { entity in
                    entity.asPreset
                }
        }
        .store(in: &cancellables)
    }
    
    func updateNewPresetName(name: String) {
        selectedPreset = Preset(id: UUID(), name: name)
        print("New name: " + selectedPreset.name)
    }
    
    private var presetUpdateListener: [AnyCancellable] = []
}
