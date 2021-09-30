//
//  NewPresetVm.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 27/09/2021.
//

import Foundation
import SwiftUI

public class NewPresetVm : ObservableObject {
    
    @Published var images = [ViewImage]()
    
    private let storage = LocalStorage()
    
    private let presetId: String

    init() {
        presetId = "Preset" + String.randomString(length: 5) + "\(Date().currentTimeMillis())"
    }
    
    func savePicture(inputImage: UIImage) {
        if let imageData = try?
            storage.saveImage(inputImage: inputImage, presetId: presetId) {
            if let image = imageData.asViewImage() {
                images.append(image)
            }
        }
    }
    
    
//    func loadImages() {
//        if let imagesList = storage.getImages(presetId: presetId) {
//            imagesList.forEach { data in
//                print("Image loaded \(data.description)")
//                if let image = UIImage(data: data) {
//                    images.append(ViewImage(image: image))
//                }
//            }
//        }
//    }
    
}

struct ViewImage: Identifiable, Hashable {
    var id = UUID()
    var image: UIImage
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
