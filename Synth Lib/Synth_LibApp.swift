//
//  Synth_LibApp.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI


@main
struct Synth_LibApp: App {
    
    let appStore: AppStore = AppStore()
    
    var body: some Scene {
        WindowGroup {
            PresetList()
                .background(Color.green)
                .ignoresSafeArea()
        }
    }
}
