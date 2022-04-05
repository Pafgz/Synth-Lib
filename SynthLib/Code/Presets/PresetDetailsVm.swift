//
//  NewPresetVm.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 27/09/2021.
//

import Foundation
import SwiftUI
import AVFoundation

final class PresetDetailsVm : ObservableObject {

    private var audioRecorder: AudioRecorder?
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    @Published var preset: Preset? = nil
    
    @Published var presetName: String = "No name"
    
    @Published var newPhoto: UIImage?
    @Published var images = [AppImageData]()
    
    @Published var newRecording: Recording?
    @Published var recordings = [Recording]()
    
    @Published var isRecording = false
    @Published var isEditMode = false
    @Published var isDeleted = false
    
    init(currentPreset: Preset?) {
            if let currentPreset = currentPreset {
                print("Opened " + currentPreset.name)
                do {
                    if let existingPreset = try? CoreDataManager.shared.loadPreset(with: currentPreset.id) {
                        preset = existingPreset
                    } else {
                        preset = try! CoreDataManager.shared.savePreset(preset: currentPreset)
                    }
                    if let preset = preset {
                        audioRecorder = AudioRecorder(preset: preset, storage: LocalStorage.shared)
                    }
                    loadImages()
                    loadRecordings()
                }
            } else {
                print("Opened Nothing")
            }
        
        if let preset = preset {
            presetName = preset.name
        }
    }
    
    func storePicture(inputImage: UIImage) {
        if let preset = preset {
            if let imageData = try? LocalStorage.shared.saveImage(inputImage: inputImage, presetId: preset.id) {
                images.append(imageData)
            }
        }
    }
    
    func updateName(name: String) {
        if preset != nil {
            self.preset!.name = name
        }
    }
    
    func savePreset() {
        if let preset = preset {
                do {
                    try self.preset = CoreDataManager.shared.savePreset(preset: preset)
                    print("Preset Saved")
                } catch {
                    print("Error saving a preset")
            }
        }
    }
    
    func loadImages() {
        if let preset = preset {
            images = LocalStorage.shared.getImages(presetId: preset.id) ?? []
            print("images loaded")
        }
    }
    
    func loadRecordings() {
        if let preset = preset {
            recordings.removeAll()
            recordings = LocalStorage.shared.getRecordings(presetId: preset.id)
            recordings.sort(by: {
                $0.createdAt.compare($1.createdAt) == .orderedAscending
            })
            print("\(recordings.count) demo loaded")
            for demo in recordings {
                print(demo.fileURL)
            }
        }
    }
    
    func deletePreset(onSuccess: () -> Void) {
        if let preset = preset {
            LocalStorage.shared.deleteFolder(presetId: preset.id)
            CoreDataManager.shared.deletePreset(preset: preset)
            onSuccess()
        }
    }
    
    func deleteImage(image: AppImageData) {
        if let preset = preset {
            let isDeleted = LocalStorage.shared.deletePicture(image: image, presetId: preset.id)
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
    
    func onTapRecord() {
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
