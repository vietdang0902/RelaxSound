//
//  BottomPopupView.swift
//  RelaxSounds
//
//  Created by VietMac on 7/7/25.
//

import SwiftUI

struct BottomPopupView: View {
    @EnvironmentObject var timerManager: TimerManager
//    @Binding var selectedSounds: [CustomSoundData]
    @Binding var showMixSound: Bool
    let deviceVolume: Double
    
    let soundCount: Int
    let isPlayingAll: Bool
    let onPlayPauseAll: () -> Void
    let onTimer: (() -> Void)?

    var body: some View {
        HStack(spacing: 30) {
            // timer
            Button(action: {
                onTimer?()
            }) {
                VStack {
                    Image(systemName: "timer")
                        .foregroundColor(.white)
                        .font(.title2)
                    if let seconds = timerManager.remainingSeconds, seconds > 0 {
                        Text(timerManager.formatTime())
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
            }

            // play/pause
            Button(action: onPlayPauseAll) {
                Image(systemName: isPlayingAll ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            }

            // count sounds
            Button(action: {
                showMixSound = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.white)
                    Text("\(soundCount)")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.85))
        )
        .shadow(radius: 8)
    }
}

