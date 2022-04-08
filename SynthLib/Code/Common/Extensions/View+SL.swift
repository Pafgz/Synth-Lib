//
//  View+SL.swift
//  SynthLib
//
//  Created by Pierre-Antoine Fagniez on 08/04/2022.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func fade(duration: CGFloat = 0.5) -> some View {
        modifier(Fade(duration: duration))
    }
}

struct Fade: ViewModifier {
    var duration: CGFloat

    func body(content: Content) -> some View {
        content
            .animation(.easeInOut, value: duration)
            .transition(.opacity)
    }
}
