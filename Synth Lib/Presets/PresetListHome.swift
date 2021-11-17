//
//  ContentView.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI

struct PresetListHome: View {
    
    @StateObject var vm: PresetVm = PresetVm()
    @EnvironmentObject var dbManager: CoreDataManager
    @State private var isShowingNewPresetNameDialog = false
    @State private var navigateToPresetDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.DarkBlue.ignoresSafeArea()
                
                VStack {
                    if(vm.presets.isEmpty) {
                        Text("No preset")
                            .font(.system(size: 28))
                            .foregroundColor(Color.white)
                        
                        Button(action: {
                            isShowingNewPresetNameDialog = true}) {
                                AddImageItem()
                            }
                        Spacer().frame(height: 250)
                    } else {
                        PresetList(presets: vm.presets, onClickPreset: { preset in
                            vm.selectedPreset = preset
                            navigateToPresetDetails = true
                        })
                    }
                    
                    NavigationLink(destination:
                                    PresetDetails(preset: vm.selectedPreset)
                                    .environmentObject(dbManager)
                                    .foregroundColor(.white), isActive: $navigateToPresetDetails) { EmptyView() }
                }
            }.navigationBarItems(trailing:
                                    Button(action: {
                isShowingNewPresetNameDialog = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.white)
            })
        }
        .alert(isPresented: $isShowingNewPresetNameDialog,
               TextAlert(title: "Create new preset",
                         message: "Enter a name for your preset",
                         keyboardType: .default) { result in
            if let text = result {
                vm.updateNewPresetName(name: text)
                navigateToPresetDetails = true
                isShowingNewPresetNameDialog = false
            } else {
                isShowingNewPresetNameDialog = false
            }
        })
        .onAppear {
            vm.setup(coreDataManager: dbManager)
        }
        .ignoresSafeArea()
    }
}



struct PresetListHome_Previews: PreviewProvider {
    static var previews: some View {
        let db = CoreDataManager.shared
        PresetListHome()
            .environmentObject(db)
    }
}

struct PresetList: View {
    var presets: [Preset]
    let onClickPreset: (Preset) -> Void
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach(presets) { preset in
                PresetItem(preset: preset,
                           playDemo: { preset in
                    print("Press Demo")
                },
                           onClickPreset: onClickPreset
                )
            }
        }.background(AppColors.DarkBlue)
    }
}

struct PresetList_Previews: PreviewProvider {
    static var previews: some View {
        PresetList(presets: PresetPreviewData.presetList, onClickPreset: {_ in})
    }
}

struct PresetItem: View {
    
    var preset: Preset
    let playDemo: (Preset) -> Void
    let onClickPreset: (Preset) -> Void
    
    var body: some View {
        Button(action: { onClickPreset(preset) }) {
            ZStack {
                AppColors.DarkGrey
                HStack() {
                    Text(preset.name)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 16)
                    
                    Spacer()
                    if(preset.hasDemo) {
                        Button(action: { playDemo(preset) }) {
                            Image(systemName: "play.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 16)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }.frame(height: 55)
    }
}



struct PresetItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PresetItem(preset: PresetPreviewData.preset1, playDemo: {_ in }) {_ in}
            PresetItem(preset: PresetPreviewData.preset2, playDemo: {_ in }) {_ in}
        }
    }
}

struct PresetPreviewData {
    static let preset1: Preset = Preset(id: UUID(),name: "Pad Horn")
    static let preset2: Preset = Preset(id: UUID(), name: "Terminator Riser", hasDemo: true)
    static let preset3: Preset = Preset(id: UUID(), name: "Air",hasDemo: true)
    static let preset4: Preset = Preset(
        id: UUID(),
        name: "Trumpet",
        hasDemo: true
    )
    
    static let preset5: Preset = Preset(
        id: UUID(),
        name: "Margulin",
        hasDemo: false
    )
    
    static let preset6 = Preset(id: UUID(), name: "Gentle Pad", hasDemo: true)
    static let preset7 = Preset(id: UUID(), name: "Drop Bass", hasDemo: false)
    static let preset8 = Preset(id: UUID(), name: "Epic Twins")
    
    static let presetList: [Preset] = [preset1, preset2, preset3, preset4, preset5, preset6, preset7, preset8]
}

