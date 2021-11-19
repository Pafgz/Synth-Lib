//
//  NewPresetVm.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 27/09/2021.
//

import Foundation
import SwiftUI
import AVFoundation

public class PresetDetailsVm : ObservableObject {
    
    private let storage = LocalStorage()
    private var audioRecorder: AudioRecorder?
    private var dbManager: CoreDataManager?
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    @Published var preset: Preset? = nil
    
    @Published var images = [AppImageData]()
    
    @Published var recordings = [Recording]()
    
    @Published var isRecording = false
    
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
                    if let preset = preset {
                        audioRecorder = AudioRecorder(preset: preset, storage: storage)
                    }
                    loadImages()
                    loadRecordings()
                }
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
    
    func loadRecordings() {
        if let preset = preset {
            recordings.removeAll()
            recordings = storage.getRecordings(presetId: preset.id)
            recordings.sort(by: {
                $0.createdAt.compare($1.createdAt) == .orderedAscending
            })
            print("\(recordings.count) demo loaded")
            for demo in recordings {
                print(demo.fileURL)
            }
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
    
    func clickRecord() {
        if(isRecording) {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        isRecording = true
        audioRecorder?.startRecording()
    }
    
    func stopRecording() {
        isRecording = false
        audioRecorder?.stopRecording()
        loadRecordings()
    }
    
    func playSound(recording: Recording) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.fileURL)
            audioPlayer?.play()
        } catch {
            print("ERROR")
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
