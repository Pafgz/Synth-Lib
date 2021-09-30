//
//  Buttons.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 30/09/2021.
//

import Foundation
import SwiftUI

struct AppButton: View {
    
    let text: String
    let bgColor: Color?
    
    public var body: some View {
        
            Text(text)
                .scaledToFill()
                .foregroundColor(Color.white)
        
        .frame(maxWidth: .infinity, minHeight: 56)
        .background(RoundedRectangle(cornerRadius: 10))
    }
}


struct AppButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppButton(text: "Click the button", bgColor: Color.gray)
            AppButton(text: "Click the button", bgColor: Color.green)
        }
    }
}
