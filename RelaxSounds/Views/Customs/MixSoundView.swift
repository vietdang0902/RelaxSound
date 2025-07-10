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
                    volume: Double(sound.volume ?? "50") ?? 50,
                    title: sound.title,
                    avatar: sound.avatar,
                    linkMusic: sound.linkMusic
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
        HStack(spacing: 16) {
            // Sound image
            AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.avatar)")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.white.opacity(0.7))
                    )
            }

            // Sound info and controls
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(sound.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("Volume: \(Int(volumePercentage))%")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red.opacity(0.8))
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                // Volume slider with 0-100 scale
                Slider(
                    value: Binding(
                        get: {
                            // Convert từ API format (0-1) sang UI scale (0-100)
                            let apiVolume = Double(sound.volume ?? "0.5") ?? 0.5
                            return apiVolume * 100  // 0.5 → 50, 1.0 → 100
                        },
                        set: { newValue in
                            // Convert từ UI scale (0-100) sang API format (0-1)
                            let apiVolume = newValue / 100.0  // 50 → 0.5, 100 → 1.0
                            print("🎚️ '\(sound.title)': \(Int(newValue))% (API: \(apiVolume))")
                            onVolumeChange(apiVolume)
                            audioManager.setVolume(for: sound.id, volume: Float(apiVolume))
                        }
                    ),
                    in: 0...100,
                    step: 1
                )
                .accentColor(.blue)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // Helper để tính percentage cho display
    private var volumePercentage: Double {
        let apiVolume = Double(sound.volume ?? "0.5") ?? 0.5
        return apiVolume * 100  // Convert API format to percentage
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
