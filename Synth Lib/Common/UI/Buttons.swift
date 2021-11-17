//
//  Buttons.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 30/09/2021.
//

import Foundation
import SwiftUI

struct AppButton: View {
    
    var text: String
    var fgColor: Color = .white
    var bgColor: Color = AppColors.Orange
    var width: CGFloat = .infinity
    var font: Font = .system(size: 20)
    var onClick: () -> Void
    
    public var body: some View {
        
        Button(action: onClick) {
            Text(text)
                .font(font)
                .foregroundColor(fgColor)
                .padding(16)
                .frame(maxWidth: width, maxHeight: 56)
                .background(RoundedRectangle(cornerRadius: 10).fill(bgColor))
        }
    }
}


struct AppButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppButton(text: "Click the button") {}
            AppButton(text: "Click the button", bgColor: Color.green) {}
        }
    }
}
