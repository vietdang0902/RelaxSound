import SwiftUI

struct DetailSoundView: View {
    @Environment(\.presentationMode) var presentationMode
    let sound: SoundModel
    @State private var showSetTimer = false
    @StateObject var timerManager = TimerManager()
    @State private var selectedTimer = "No timer"

    @State private var showCustomSound = false
    @State private var selectedCustomSounds: [CustomSoundData] = []

    var body: some View {
        ZStack {
            DetailSoundContent(sound: sound, showSetTimer: $showSetTimer, showCustomSound: $showCustomSound, selectedCustomSounds: $selectedCustomSounds)
                .environmentObject(timerManager)
                .navigationTitle(sound.title)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showSetTimer) {
            SetTimerView(isPresented: $showSetTimer, selectedTimer: $selectedTimer)
                .environmentObject(timerManager)
                .presentationDetents([.fraction(0.65)])
        }
        .sheet(isPresented: $showCustomSound) {
            DetailCustomSound(selectedSounds: $selectedCustomSounds)
        }
    }
}

struct DetailSoundContent: View {
    let sound: SoundModel
    @Binding var showSetTimer: Bool
    @Binding var showCustomSound: Bool
    @Binding var selectedCustomSounds: [CustomSoundData]
    @StateObject var audioManager = AudioManager()
    @State private var isPlayingAll = false
    @State private var isMainSoundEnabled = true
    @State private var mainSoundVolume: Float = 0.5

    @EnvironmentObject private var timerManager: TimerManager

    @State private var previousCustomSoundsCount = 0

    var body: some View {
        ZStack {
            backgroundImage
            
            VStack(spacing: 15) {
                timerSection
                mainSoundControlSection
                addCustomSoundButton
                customSoundsSection
                Spacer()
                playPauseButton
            }
            .onChange(of: timerManager.remainingSeconds) { newValue in
                if let seconds = newValue, seconds == 0 {
                    audioManager.stopAll()
                    isPlayingAll = false
                }
            }
            .onChange(of: selectedCustomSounds) { newCustomSounds in
                handleCustomSoundsChange(newCustomSounds)
            }
            .padding(.top, 10)
        }
    }
    
    private var backgroundImage: some View {
        AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.imageName)")) { image in
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
    
    private var mainSoundControlSection: some View {
        VStack(spacing: 12) {
            nowPlayingSection
            mainSoundControls
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
    
    private var nowPlayingSection: some View {
        Group {
            if isMainSoundEnabled {
                HStack {
                    Text("Now Playing:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(audioManager.currentMusicTitle.isEmpty ? sound.title : audioManager.currentMusicTitle)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    Spacer()
                }
            }
        }
    }
    
    private var mainSoundControls: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "speaker.wave.1.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                
                Slider(value: Binding(
                    get: { Double(mainSoundVolume) },
                    set: { mainSoundVolume = Float($0) }
                ), in: 0...1) { editing in
                    if !editing {
                        audioManager.setVolume(for: sound.id, volume: mainSoundVolume)
                    }
                }
                .accentColor(.blue)
                
                Text("\(Int(mainSoundVolume * 100))%")
                    .foregroundColor(.white)
                    .font(.caption)
                    .frame(width: 35)
            }
        }
    }
    
    private var addCustomSoundButton: some View {
        VStack {
            Button(action: { showCustomSound = true }) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
            .shadow(radius: 6)
        }
    }
    
    private var customSoundsSection: some View {
        Group {
            if !selectedCustomSounds.isEmpty {
                VStack {
                    Text("Sounds added: \(selectedCustomSounds.count)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach($selectedCustomSounds) { $custom in
                                CustomSoundRow(
                                    custom: $custom,
                                    onRemove: { id in
                                        audioManager.stop(for: id)
                                        if let idx = selectedCustomSounds.firstIndex(where: { $0.id == id }) {
                                            selectedCustomSounds.remove(at: idx)
                                        }
                                    },
                                    onVolumeChange: { newValue in
                                        audioManager.setVolume(for: custom.id, volume: newValue)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: 400)
                }
            }
        }
    }
    
    var playPauseButton: some View {
        Button(action: {
            if audioManager.isPlaying {
                audioManager.pause()
            } else {
                if audioManager.hasAudioLoaded {
                    audioManager.resume()
                } else {
                    if isMainSoundEnabled {
                        audioManager.playWithMainSound(sound, customSounds: selectedCustomSounds)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            audioManager.setVolume(for: sound.id, volume: mainSoundVolume)
                        }
                    } else {
                        audioManager.play(sounds: selectedCustomSounds)
                    }
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .green.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
//            Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                .resizable()
//                .frame(width: 60, height: 60)
//                .foregroundColor(.white)
//                .shadow(radius: 10)
        }
        .padding(.bottom, 24)
    }
    
    private func handleCustomSoundsChange(_ newCustomSounds: [CustomSoundData]) {
        print("CustomSounds changed: \(newCustomSounds.count) sounds, previous: \(previousCustomSoundsCount)")
        print("AudioManager isPlaying: \(audioManager.isPlaying), isMainSoundEnabled: \(isMainSoundEnabled)")
        
        // Chỉ thêm custom sounds mới nếu đang phát và có main sound
        if audioManager.isPlaying && isMainSoundEnabled && newCustomSounds.count > previousCustomSoundsCount {
            print("Adding new custom sounds...")
            // Tìm custom sounds mới được thêm
            let newSounds = newCustomSounds.suffix(newCustomSounds.count - previousCustomSoundsCount)
            for newSound in newSounds {
                print("Adding custom sound: \(newSound.title ?? "Unknown")")
                audioManager.addCustomSound(newSound)
            }
        }
        previousCustomSoundsCount = newCustomSounds.count
    }
}

#Preview {
    DetailSoundView(sound: SoundModel(
        id: 1,
        avatar: "sample.jpg",
        title: "Sample Sound",
        slug: "sample-sound",
        status: 1,
        createdAt: "2025-07-01T00:00:00Z",
        updatedAt: "2025-07-01T00:00:00Z"
    ))
}
