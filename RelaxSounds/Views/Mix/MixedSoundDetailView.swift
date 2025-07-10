import SwiftUI

struct MixedSoundDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let mixedSound: MixedSoundModel
    @State private var showSetTimer = false
    @StateObject var timerManager = TimerManager()
    @State private var selectedTimer = "No timer"

    var body: some View {
        ZStack {
            MixedSoundDetailContent(mixedSound: mixedSound, showSetTimer: $showSetTimer)
                .environmentObject(timerManager)
                .navigationTitle(mixedSound.title)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showSetTimer) {
            SetTimerView(isPresented: $showSetTimer, selectedTimer: $selectedTimer)
                .environmentObject(timerManager)
                .presentationDetents([.fraction(0.65)])
        }
    }
}

struct MixedSoundDetailContent: View {
    let mixedSound: MixedSoundModel
    @Binding var showSetTimer: Bool
    @StateObject var audioManager = AudioManager()
    @State private var isPlayingAll = false
    @State private var editableMixedSounds: [MixedSound] = []

    @EnvironmentObject private var timerManager: TimerManager

    var body: some View {
        ZStack {
            backgroundImage

            VStack(spacing: 15) {
                timerSection
                mixedSoundsSection
                Spacer()
                playPauseButton
            }
            .onChange(of: timerManager.remainingSeconds) { newValue in
                if let seconds = newValue, seconds == 0 {
                    audioManager.stopAll()
                    isPlayingAll = false
                }
            }
            .padding(.top, 10)
        }
        .onAppear {
            editableMixedSounds = mixedSound.mixedSounds
        }
    }

    private var backgroundImage: some View {
        AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(mixedSound.imageName)")) { image in
            image
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 18)
        } placeholder: {
            Color.gray.opacity(0.9)
                .ignoresSafeArea()
        }
    }

    private var timerSection: some View {
        HStack(spacing: 32) {
            Button(action: { showSetTimer = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 240, height: 60)
                        .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)

                    if let seconds = timerManager.remainingSeconds, seconds > 0 {
                        Text(timerManager.formatTime())
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.white)
                            Text("Set Timer")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(showSetTimer ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showSetTimer)
        }
    }

    private var mixedSoundsSection: some View {
        VStack(spacing: 12) {
            mixedSoundsList
//            savedMixedSoundsList
        }
        .frame(maxWidth: 350)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }

    private var mixedSoundsList: some View {
        Group {
            if editableMixedSounds.isEmpty {
                VStack {
                    Text("No sounds in this mix")
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxHeight: 200)
            } else {
                // Đơn giản hóa - không cần SoundViewModel nữa
                SoundListView(
                    editableMixedSounds: $editableMixedSounds,
                    updateAction: updateMixedSoundInStorage
                )
            }
        }
    }

    private func updateMixedSoundInStorage() {
        // Lưu trực tiếp vào UserDefaults thông qua một helper function
        saveMixedSoundToUserDefaults()
    }
    
    private func saveMixedSoundToUserDefaults() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(editableMixedSounds) {
            UserDefaults.standard.set(data, forKey: "mixedSound_\(mixedSound.id)")
        }
    }

    private var playPauseButton: some View {
        Button(action: {
            if isPlayingAll {
                audioManager.stopAll()
            } else {
                audioManager.playMixedSounds(mixedSound)
            }
            isPlayingAll.toggle()
        }) {
            ZStack {
                Circle()
                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color.green, Color.blue]),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .green.opacity(0.4), radius: 20, x: 0, y: 10)

                Image(systemName: isPlayingAll ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPlayingAll ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlayingAll)
        .padding(.bottom, 30)
    }
}

struct SoundListView: View {
    @Binding var editableMixedSounds: [MixedSound]
    var updateAction: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(editableMixedSounds.enumerated()), id: \.element.soundId) { index, sound in
                    MixedSoundRow(
                        mixedSound: sound,
                        onVolumeChange: { newVolume in
                            editableMixedSounds[index] = MixedSound(
                                soundId: sound.soundId,
                                volume: Double(newVolume),
                                title: sound.title,
                                avatar: sound.avatar,
                                linkMusic: sound.linkMusic
                            )
                            updateAction()
                        },
                        onRemove: {
                            editableMixedSounds.remove(at: index)
                            updateAction()
                        }
                    )
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

struct MixedSoundRow: View {
    let mixedSound: MixedSound
    var onVolumeChange: (Double) -> Void
    var onRemove: () -> Void

    @State private var currentVolume: Double

    init(mixedSound: MixedSound, onVolumeChange: @escaping (Double) -> Void, onRemove: @escaping () -> Void) {
        self.mixedSound = mixedSound
        self.onVolumeChange = onVolumeChange
        self.onRemove = onRemove
        _currentVolume = State(initialValue: mixedSound.volume)
    }

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(mixedSound.avatar)")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(mixedSound.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .bold()
                Text("Volume: \(Int(currentVolume))%")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Slider(value: $currentVolume, in: 0 ... 100, step: 1)
                .accentColor(.purple)
                .frame(width: 100)
                .onChange(of: currentVolume) { newValue in
                    onVolumeChange(newValue)
                }

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
        .onAppear {
            currentVolume = mixedSound.volume
        }
    }
}
