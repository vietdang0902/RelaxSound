//
//  SliderCustom.swift
//  RelaxSounds
//
//  Created by VietMac on 7/7/25.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let thumbSize: CGFloat
    let trackHeight: CGFloat
    let accentColor: Color

    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - thumbSize
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let xPosition = progress * width

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trackHeight)

                // Track filled
                Capsule()
                    .fill(accentColor)
                    .frame(width: xPosition + thumbSize / 2, height: trackHeight)

                // Thumb
                Circle()
                    .fill(accentColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: xPosition)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onChanged { gesture in
                                let newX = min(max(0, xPosition + gesture.translation.width), width)
                                let newValue = Double(newX / width) * (range.upperBound - range.lowerBound) + range.lowerBound
                                self.value = newValue
                            }
                    )
            }
            .animation(.easeInOut(duration: 0.1), value: value)
        }
        .frame(height: max(thumbSize, trackHeight))
    }
}
