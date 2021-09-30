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

    func saveImage(inputImage: UIImage, presetId: String) throws -> Data? {
        let imageName = "image\(Date().currentTimeMillis())"
        if let image = inputImage.jpegData(compressionQuality: 1.0) {
            
            if let folderUrl = createFolder(folderName: presetId) {
                let filename = folderUrl.appendingPathComponent("\(imageName).jpeg")
                print(filename)
                try? image.write(to: filename)
                print("File creation done!")
                return try? Data(contentsOf: filename)
            }
        } 
        return nil
    }
    
    
    func getImages(presetId: String) -> [Data]? {
        let path = getDocumentsDirectory().path + "/" + presetId
        var images = [Data]()
        do {
            let items = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil)
                .filter{ $0.pathExtension == "jpeg" }

            for item in items {
                print("Found \(item)")
                    
                images.append(
                    try Data(contentsOf: item)
                )
                
            }
            
            return images
        } catch {
            print("Failed to read the folder")
        }
        return nil
    }
    
    func loadImage() {
        
        
    }
    
//    func getImages(presetId: Int) -> [UIImage] {
//       return nil
//   }
    
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
    
    func getDocumentsDirectory() -> URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

class CustomPhotoAlbum {

    static let albumName = "Synth Lib Presets"
    static let sharedInstance = CustomPhotoAlbum()

    var assetCollection: PHAssetCollection!

    init() {

        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
//            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//
//            if let firstObject: AnyObject = collection.firstObject {
//                return collection.firstObject as! PHAssetCollection
//            }

            return nil
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }

    func saveImage(image: UIImage) {

        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }

        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
        }, completionHandler: nil)
    }


}
