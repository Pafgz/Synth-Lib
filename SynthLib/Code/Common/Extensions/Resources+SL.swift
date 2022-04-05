//
//  Resources+SL.swift
//  SynthLib
//
//  Created by Pierre-Antoine Fagniez on 05/04/2022.
//

import Rswift
import SwiftUI
import UIKit

extension ColorResource {
    var color: Color {
        Color(name, bundle: nil)
    }

    var uiColor: UIColor {
        UIColor(named: name)!
    }
}

extension ImageResource {
    var uiImage: UIImage {
        UIImage(named: name)!
    }

    var image: Image {
        Image(uiImage: uiImage)
    }
}
