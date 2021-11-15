//
//  FileManager.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 27/09/2021.
//

import Foundation
import SwiftUI
import Photos

public class LocalStorage: ObservableObject {
    
    let fileManager = FileManager.default
    
    func saveImage(inputImage: UIImage, presetId: UUID) throws -> AppImageData? {
        let imageName = "image\(Date().currentTimeMillis)"
        if let image = inputImage.jpegData(compressionQuality: 1.0) {
            
            if let folderUrl = createFolder(folderName: presetId.uuidString) {
                let filename = folderUrl.appendingPathComponent("\(imageName).jpeg")
                print(filename)
                try? image.write(to: filename)
                print("File creation done!")
                return try? AppImageData(data: Data(contentsOf: filename), path: filename.path)
            }
        }
        return nil
    }
    
    func getImages(presetId: UUID) -> [AppImageData]? {
        let path = getPresetFolder(presetId: presetId)
        var images = [AppImageData]()
        do {
            let items = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil)
                .filter{ $0.pathExtension == "jpeg" }
            
            for item in items {
                print("Found \(item)")
                
                images.append(
                    try AppImageData(data: Data(contentsOf: item), path: item.path)
                )
                
            }
            return images
        } catch {
            print("Failed to read the folder")
        }
        return nil
    }
    
    func deletePicture(image: AppImageData, presetId: UUID) -> Bool {
        do {
            if fileManager.fileExists(atPath: image.path) {
                try fileManager.removeItem(atPath: image.path)
                print("Deleted " + image.path)
                return true
            }
            return false
        } catch {
            print("Failed to delete file " + image.path)
            return false
        }
    }
    
    func deleteFolder(presetId: UUID) -> Bool {
        let path = getPresetFolder(presetId: presetId)
        do {
            let fileName = try fileManager.contentsOfDirectory(atPath: path)
            
            for file in fileName {
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: path).appendingPathComponent(file).absoluteURL
                try fileManager.removeItem(at: filePath)
            }
           try fileManager.removeItem(atPath: path)
            return false
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
    
    private func createFolder(folderName: String) -> URL? {
        
        do {
            let documentUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            print("documentUrl -> \(documentUrl)")
            
            let dataURL = documentUrl.appendingPathComponent(folderName)
            print("dataPath.path -> \(dataURL.path)")
            if !fileManager.fileExists(atPath: dataURL.path) {
                try fileManager.createDirectory(at: dataURL, withIntermediateDirectories: false, attributes: nil)
                print("Folder creation done!")
            }
            return dataURL
        } catch { print(error) }
        
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func getPresetFolder(presetId: UUID) -> String {
        return getDocumentsDirectory().path + "/" + presetId.uuidString
    }
}

struct AppImageData: Identifiable {
    var id: UUID = UUID()
    var data: Data
    var path: String
}
