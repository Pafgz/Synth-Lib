//
//  ContentView.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI

struct PresetList: View {
    
    @ObservedObject var vm: PresetVm = PresetVm()
    @EnvironmentObject var dbManager: CoreDataManager
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    if(vm.presets.isEmpty) {
                        Text("No preset")
                        
                        NavigationLink(destination: PresetDetails()) {
                            AddImageItem()
                                .frame(width: 250, height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    } else {
                        ForEach(vm.presets, id: \.id) { preset in
                            NavigationLink(destination: PresetDetails(preset: preset)) {
                                PresetItem(preset: preset, playDemo: { preset in
                                    print("Press Demo")
                                })
                            }
                        }
                    }
                }
            }
            .navigationBarItems(trailing:
                                    NavigationLink(destination: PresetDetails()) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            )
        }
        .onAppear {
            vm.setup(coreDataManager: dbManager)
        }
        .ignoresSafeArea()
    }
}

struct PresetList_Previews: PreviewProvider {
    static var previews: some View {
        let db = CoreDataManager.shared
        PresetList()
            .environmentObject(db)
    }
}

struct PresetItem: View {
    
    var preset: Preset
    let playDemo: (Preset) -> Void
    //    let onClickPreset: (Preset) -> Void
    
    var body: some View {
        VStack {
            //        Button(action: { onClickPreset(preset) }) {
            //
            HStack() {
                Text(preset.name)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                Spacer()
                
                Button(action: { playDemo(preset) }) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 16)
                }
            }
            //            }
            Divider()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 45)
    }
}



struct PresetItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PresetItem(preset: PresetPreviewData.preset1, playDemo: {_ in })
            PresetItem(preset: PresetPreviewData.preset2, playDemo: {_ in })
        }
    }
}

struct PresetPreviewData {
    static let preset1: Preset = Preset(
        id: "452637tyureghj",
        name: "Pad Horn"
    )
    static let preset2: Preset = Preset(
        id: "5283674yh9",
        name: "Terminator Riser",
        hasDemo: true
    )
    static let preset3: Preset = Preset(
        id: "5283674r786tifyuyh9",
        name: "Air",
        hasDemo: true
    )
    static let preset4: Preset = Preset(
        id: "586tifyuyh9",
        name: "Trumpet",
        hasDemo: true
    )
    
    static let preset5: Preset = Preset(
        id: "586ti726t8igufyuyh9",
        name: "Margulin",
        hasDemo: false
    )
    
    //    let presetList: [Preset] = [preset1, preset2, preset3, preset4, preset5]
}
