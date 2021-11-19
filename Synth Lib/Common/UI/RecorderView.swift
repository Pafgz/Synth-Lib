//
//  RecorderView.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 17/11/2021.
//

import Foundation
import SwiftUI

struct RecorderView: View {
    
    @State var isRecording: Bool
    var onClickRecord: () -> Void
    
    
    var body: some View {
        Button(action: {
            isRecording = !isRecording
            onClickRecord()
        }) {
            if (isRecording) {
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .foregroundColor(.red)
                    .padding(.bottom, 40)
            } else {
                Image(systemName: "circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .foregroundColor(.red)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct RecorderView_Previews: PreviewProvider {
    static var previews: some View {
        RecorderView(isRecording: false) {}
    }
}
