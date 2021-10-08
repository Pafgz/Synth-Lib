//
//  AppStore.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 29/09/2021.
//

import Foundation

class CoreStore: ObservableObject {
    
    let localStorage: LocalStorage
    
    init() {
        localStorage = LocalStorage()
    }
}
