import SwiftUI
import AVFoundation
import MediaPlayer

struct MixSoundView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSounds: [CustomSoundData]
    @ObservedObject private var audioManager = AudioManager()
    @StateObject private var viewModel = SoundViewModel()
    @State private var systemVolume: Double
    @State private var showingSaveCustomView = false

    init(selectedSounds: Binding<[CustomSoundData]>, audioManager: AudioManager, deviceVolume: Double) {
        _selectedSounds = selectedSounds
        self.audioManager = audioManager
        _systemVolume = State(initialValue: deviceVolume)
    }
    
    private func handleSaveCustom(_ data: String) {
        let components = data.split(separator: "|")
        if components.count == 2 {
            let name = String(components[0])
            let avatar = String(components[1])
            
            // Create mixed sounds array
            let mixedSounds = selectedSounds.map { sound in
                MixedSound(
                    soundId: sound.id,
                    volume: Double(sound.volume ?? "50") ?? 50
                )
            }
            
            // Save mixed sound using the current view model instance
            viewModel.saveMixedSound(title: name, avatar: avatar, mixedSounds: mixedSounds)
            
            dismiss()
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                ScrollView {
                    VStack(spacing: 28) {
                        Text("Selected sounds: \(selectedSounds.count)")
                            .foregroundColor(.white)
                            .onAppear {
                                print("MixSoundView received \(selectedSounds.count) sounds")
                                selectedSounds.forEach { sound in
                                    print("Sound: \(sound.title)")
                                }
                            }
                        ForEach(selectedSounds.indices, id: \.self) { index in
                            SoundSliderRow(
                                sound: selectedSounds[index],
                                onVolumeChange: { newVolume in
                                    selectedSounds[index].volume = String(newVolume)
                            },
                                onRemove: {
                                    audioManager.stop(for: selectedSounds[index].id)
                                    selectedSounds.remove(at: index)
                            },
                                audioManager: audioManager
                            )
                        }
                    }

                    Button(action: {
                        showingSaveCustomView = true
                    }) {
                        Text("Save Mix")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(selectedSounds.isEmpty)
                    .padding(.top, 10)

                    Spacer()

                    CancelButton(dismiss: dismiss)
                }
                .padding(32)
                .cornerRadius(24)
                .background(Color(red: 13 / 255, green: 24 / 255, blue: 54 / 255))
                .ignoresSafeArea()
            }
            
            if showingSaveCustomView {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingSaveCustomView = false
                    }
                
                SaveCustomView(
                    isPresented: $showingSaveCustomView,
                    onSave: handleSaveCustom
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut, value: showingSaveCustomView)
                .transition(.opacity)
            }
        }
    }
}

private struct SoundSliderRow: View {
    let sound: CustomSoundData
    let onVolumeChange: (Double) -> Void
    let onRemove: () -> Void
    @ObservedObject var audioManager = AudioManager()
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.avatar)")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }

            Slider(
                value: Binding(
                    get: { Double(sound.volume ?? "0.5") ?? 0.5 },
                    set: { newValue in
                        onVolumeChange(newValue)
                        audioManager.setVolume(for: sound.id, volume: Float(newValue))
                    }
                ),
                in: 0 ... 1
            )
            .accentColor(.white)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

private struct CancelButton: View {
    let dismiss: DismissAction

    var body: some View {
        HStack {
            Spacer()
            Button("Close", action: dismiss.callAsFunction)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
        }
    }
}
