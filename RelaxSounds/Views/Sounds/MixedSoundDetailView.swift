import SwiftUI

struct MixedSoundDetailView: View {
    let mixedSound: MixedSoundModel
    @StateObject private var viewModel = SoundViewModel()
    @StateObject private var audioManager = AudioManager()
    @State private var isPlayingAll = false
    @EnvironmentObject private var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Mixed Sounds")
                .font(.title2)
                .foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(mixedSound.mixedSounds, id: \.soundId) { sound in
                        if let originalSound = viewModel.sounds.first(where: { $0.id == sound.soundId }) {
                            MixedSoundRow(
                                mixedSound: sound,
                                originalSound: originalSound,
                                onVolumeChange: { newVolume in
                                    audioManager.setVolume(for: sound.soundId, volume: Float(newVolume/100.0))
                                },
                                onRemove: {
                                    // Handle remove sound from mix
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Play/Pause Button
            Button(action: {
                if isPlayingAll {
                    audioManager.stopAll()
                } else {
                    // Play all sounds in mix with their volumes
                    for sound in mixedSound.mixedSounds {
                        if let originalSound = viewModel.sounds.first(where: { $0.id == sound.soundId }) {
                            // TODO: Implement play with volume
                        }
                    }
                }
                isPlayingAll.toggle()
            }) {
                Image(systemName: isPlayingAll ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            viewModel.loadSounds()
        }
    }
}