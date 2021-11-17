//
//  NewPresetVm.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 27/09/2021.
//

import Foundation
import SwiftUI

public class PresetDetailsVm : ObservableObject {
    
    @Published var images = [AppImageData]()
    
    private let notif = NotificationCenter.default
    
    private let storage = LocalStorage()
    
    private var dbManager: CoreDataManager?
    
    @Published var preset: Preset? = nil
    
    func setup(coreDataManager: CoreDataManager, currentPreset: Preset?) {
        if(dbManager == nil) {
            dbManager = coreDataManager
            if let currentPreset = currentPreset {
                print("Opened " + currentPreset.name)
                do {
                    if let existingPreset = try? dbManager!.loadPreset(with: currentPreset.id) {
                        preset = existingPreset
                    } else {
                        preset = try! dbManager!.savePreset(preset: currentPreset)
                    }
                }
                loadImages()
            } else {
                print("Opened Nothing")
            }
        }
    }
    
    func storePicture(inputImage: UIImage) {
        if let preset = preset {
            if let imageData = try? storage.saveImage(inputImage: inputImage, presetId: preset.id) {
                images.append(imageData)
            }
        }
    }
    
    func updateName(name: String) {
        if let preset = preset {
            self.preset!.name = name
            print("Name updated with " + preset.name)
        }
    }
    
    func savePreset() {
        if let preset = preset {
            if let dbManager = dbManager {
                do {
                    try self.preset = dbManager.savePreset(preset: preset)
                    print("Preset Saved")
                } catch {
                    print("Error saving a preset")
                }
            }
        }
    }
    
    func loadImages() {
        if let preset = preset {
            images = storage.getImages(presetId: preset.id) ?? []
            print("images loaded")
        }
    }
    
    func deletePreset() -> Bool {
        if let preset = preset {
            storage.deleteFolder(presetId: preset.id)
            dbManager?.deletePreset(preset: preset)
            return true
        }
        return false
    }
    
    func deleteImage(image: AppImageData) {
        if let preset = preset {
            let isDeleted = storage.deletePicture(image: image, presetId: preset.id)
            if(isDeleted) {
                let i = images.firstIndex { item in
                    item.path == image.path
                }
                if let index = i {
                    images.remove(at: index)
                }
            }
        }
    }
}

extension AppImageData {
    func asUIImage() -> UIImage? {
        return UIImage(data: data) ?? nil
    }
}

extension Array {
    public func forEachIndexed(body: (Int, Element) -> Void) {
        for (index, element) in enumerated() {
            body(index, element)
        }
    }
}
