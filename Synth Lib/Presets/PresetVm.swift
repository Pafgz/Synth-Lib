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
    
    @Published var presets = [Preset]()
    
    init() {
//        let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(didSave(_:)),
//            name: didSaveNotification, object: nil
//        )
    }
    
    func setup(coreDataManager: CoreDataManager) {
        dbManager = coreDataManager
        loadPresets()
        listenToPresetUpdates()
    }
    
    func loadPresets() {
        do {
            if let dbManager = dbManager {
                presets = try dbManager.loadPresets()
                print("Loaded \(presets.count)")
            }
        } catch {
            print("Error retrieving presets")
        }
    }
    
    private var presetUpdateListener: [AnyCancellable] = []
    
    func listenToPresetUpdates(){
        NotificationCenter.default.publisher(for: .updatePresets)
            .map{$0.object as! Bool}
            .sink { isUpdated in
                self.loadPresets()
            }.store(in: &presetUpdateListener)
    }
}

extension Notification.Name {
    static let updatePresets = Notification.Name("updatePresets")
    
}
