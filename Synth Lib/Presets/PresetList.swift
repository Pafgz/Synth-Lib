//
//  ContentView.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI

struct PresetList: View {
    
//    @EnvironmentObject var vm: PresetVm
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text("Placeholder")
                Text("Hello, world!").padding()
            })
            .navigationBarItems(trailing:
                                    NavigationLink(destination: NewPreset()) {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                    }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PresetList()
    }
}


