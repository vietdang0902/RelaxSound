//
//  PressButtonEffect.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 26/6/25.
//

import SwiftUI

struct PressedEffect: ViewModifier {
    @GestureState private var isPressed = false
    func body(content: Content) -> some View {
        content
            .opacity(isPressed ? 0.5 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
            .animation(.easeOut(duration: 0.2), value: isPressed)
    }
}

extension View {
    func pressedEffect() -> some View {
        self.modifier(PressedEffect())
    }
}
