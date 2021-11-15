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
    @StateObject var db = CoreDataManager.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            PresetListHome()
                .environmentObject(db)
                .background(AppColors.DarkBlue)
                .ignoresSafeArea()
        }
        .onChange(of: scenePhase) { _ in
            db.save(onConflict: nil)
        }
    }
}
