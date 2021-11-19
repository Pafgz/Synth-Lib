//
//  AudioRecorder.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 17/11/2021.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioRecorder {
    
    let localStorage: LocalStorage
    
    var audioRecorder: AVAudioRecorder!
    
    var presetId: UUID
    
    init(preset: Preset, storage: LocalStorage) {
        presetId = preset.id
        localStorage = storage
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            localStorage.createFolder(folderName: presetId.uuidString)
            
            let audioFilename = localStorage.getPresetFolderUrl(presetId: presetId).appendingPathComponent("\(Date().toString()).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.record()
            } catch {
                print("Could not start recording")
            }
        } catch {
            print("Failed to set up recording session")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
    }
}

struct Recording {
    let fileURL: URL
    let createdAt: Date
}
