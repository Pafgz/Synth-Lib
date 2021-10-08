//
//  NewPresetVm.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 27/09/2021.
//

import Foundation
import SwiftUI

public class PresetDetailsVm : ObservableObject {
    
    @Published var images = [ViewImage]()
    
    @Published var hasChanges = false
    
    private let notif = NotificationCenter.default
    
    private let storage = LocalStorage()
    
    private var dbManager: CoreDataManager?
    
    @Published var preset: Preset
    
    init() {
        let presetId = "Preset" + String.randomString(length: 5) + "\(Date().currentTimeMillis)"
        preset = Preset(id: presetId, name: presetId)
    }
    
    func setup(coreDataManager: CoreDataManager, currentPreset: Preset?) {
        dbManager = coreDataManager
        if let currentPreset = currentPreset {
            preset = currentPreset
            loadImages()
        }
    }
    
    func storePicture(inputImage: UIImage) {
        if let imageData = try? storage.saveImage(inputImage: inputImage, presetId: preset.id) {
            if let image = imageData.asViewImage() {
                image.isSaved = true
                hasChanges = true
            }
        }
    }
    
    func storeAllPictures(pictureList: [ViewImage]) {
        pictureList.filter{ image in
            !image.isSaved
        }.forEachIndexed { index, image in
                let result = try? storage.saveImage(inputImage: image.image, presetId: preset.id)
                if let result = result {
                    pictureList[index].isSaved = true
                    print("picture \(index) is saved")
                }
        }
    }
    
    func addPhotoToPreset(inputImage: UIImage) {
        images.append(ViewImage(image: inputImage))
        hasChanges = true
        print("Photo added to preset")
    }
    
    func updateName(name: String) {
        preset.name = name
        hasChanges = true
        print("Name updated")
    }
    
    func savePreset() {
        if let dbManager = dbManager {
            do {
                try dbManager.savePreset(preset: preset)
                storeAllPictures(pictureList: images)
                sendUpdate()
            } catch {
                print("Error saving a preset")
            }
        }
    }
    
    func sendUpdate(){
        notif.post(name: .updatePresets, object: true)
    }
    
    func loadImages() {
        let dataList: [Data] = storage.getImages(presetId: preset.id) ?? []
        let imageList: [ViewImage] = dataList.compactMap { data in
            if let image = UIImage(data: data) {
                
                return ViewImage(image: image, isSaved: true)
            } else {
                return nil
            }
        }
        images = imageList
        print("images loaded")
    }
}

class ViewImage: Identifiable {
    var id = UUID()
    var image: UIImage
    var isSaved: Bool = false
    
    init(image: UIImage, isSaved: Bool = false) {
        self.image = image
        self.isSaved = isSaved
    }
}

extension Data {
    func asViewImage() -> ViewImage? {
        if let image = UIImage(data: self) {
            return ViewImage(image: image)
        } else {
            return nil
        }
    }
}

extension Array {
    
    public func forEachIndexed(body: (Int, Element) -> Void) {
        for (index, element) in enumerated() {
            body(index, element)
        }
    }
}
