//
//  Synth_LibApp.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI
import CoreData
import PartialSheet

@main
struct Synth_LibApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            PresetListHome()
                .background(R.color.darkBlue.color)
                .ignoresSafeArea()
                .attachPartialSheetToRoot()
        }
        .onChange(of: scenePhase) { _ in
            CoreDataManager.shared.save(onConflict: nil)
        }
    }
}
