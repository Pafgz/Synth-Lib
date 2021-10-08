//
//  Synth_LibApp.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI
import CoreData


@main
struct Synth_LibApp: App {
    
    let appStore: CoreStore = CoreStore()
    let db = CoreDataManager.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            PresetList()
                .environmentObject(db)
                .background(Color.green)
                .ignoresSafeArea()
        }
        .onChange(of: scenePhase) { _ in
            db.save(onConflict: nil)
        }
    }
}
