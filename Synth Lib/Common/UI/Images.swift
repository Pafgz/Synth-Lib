//
//  Images.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 14/11/2021.
//

import Foundation
import SwiftUI

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}
