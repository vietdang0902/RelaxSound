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
    @StateObject private var viewModel = SoundViewModel()
    @StateObject var audioManager = AudioManager()
    @State private var isPlayingAll = false
    
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
            viewModel.loadSounds()
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
            currentMixedSoundTitle
            mixedSoundsList
            savedMixedSoundsList
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
    
    private var currentMixedSoundTitle: some View {
        Text("Current Mix: \(mixedSound.title)")
            .font(.headline)
            .foregroundColor(.white)
            .bold()
            .padding(.bottom, 8)
    }
    
    private var mixedSoundsList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(mixedSound.mixedSounds, id: \.soundId) { sound in
                    if let originalSound = viewModel.sounds.first(where: { $0.id == sound.soundId }) {
                        HStack {
                            AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(originalSound.avatar)")) { image in
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
                                Text(originalSound.title)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .bold()
                                Text("Volume: \(Int(sound.volume))%")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "waveform")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
            }
        }
        .frame(maxHeight: 200)
    }
    
    private var savedMixedSoundsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !viewModel.mixedSounds.isEmpty {
                HStack {
                    Text("Saved Mixes")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.mixedSounds) { savedMix in
                            if savedMix.id != mixedSound.id { // Don't show the current mix in the saved list
                                HStack {
                                    AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(savedMix.avatar)")) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } placeholder: {
                                        Image(systemName: "music.note.list")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Text(savedMix.title)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("\(savedMix.mixedSounds.count) sounds")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .onTapGesture {
                                    // Play the selected saved mix when tapped
                                    audioManager.stopAll()
                                    audioManager.playMixedSounds(savedMix)
                                    isPlayingAll = true
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
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
