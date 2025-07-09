import Foundation
import SwiftUI

struct CustomSoundView: View {
    var onSelect: ((CustomSoundData) -> Void)? = nil
    @StateObject private var viewModel = SoundDataViewModel()
    var body: some View {
        CustomGridSoundView(viewModel: viewModel, onSelect: onSelect)
            .onAppear {
                viewModel.fetchSounds()
            }
            .background(
                Image("bgApp")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 15)
            )
    }
}

struct CustomGridSoundView: View {
    @ObservedObject var viewModel: SoundDataViewModel

    var onSelect: ((CustomSoundData) -> Void)? = nil
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @StateObject private var audioManager = AudioManager()
    @StateObject var timerManager = TimerManager()
    @State private var selectedTimer: String = "No timer"

    @State private var showVolumeForSlugs: [String] = []
    @State private var volumes: [String: Float] = [:]

    @State private var showSetTimer = false

    @State private var selectedSounds: [CustomSoundData] = []
    @State private var isPlayingAll = false

    @State private var deviceVolume: Double = 0.5
    @State private var showMixSound = false

    var groupedSounds: [(key: String, value: [CustomSoundData])] {
        let dict = Dictionary(grouping: viewModel.sounds, by: { $0.category })
        return dict.sorted { $0.key < $1.key }
    }

    var selectedCustomSounds: [CustomSoundData] {
        viewModel.sounds.filter { showVolumeForSlugs.contains($0.slug) }
    }

    private func volumeBinding(for sound: CustomSoundData) -> Binding<Float> {
        Binding<Float>(
            get: {
                volumes[sound.slug] ?? 0.5
            },
            set: { newValue in
                volumes[sound.slug] = newValue
                if newValue == 0 {
                    audioManager.stop(for: sound.id)
                    if let idx = showVolumeForSlugs.firstIndex(of: sound.slug) {
                        showVolumeForSlugs.remove(at: idx)
                    }
                    if showVolumeForSlugs.isEmpty {
                        isPlayingAll = false
                    }
                } else if isPlayingAll {
                    audioManager.play(sounds: [sound]) // Pass array of CustomSoundData
                    audioManager.setVolume(for: sound.id, volume: newValue)
                }
            }
        )
    }

    @ViewBuilder
    func soundCell(for sound: CustomSoundData) -> some View {
        VStack(spacing: 4) {
            Button(action: {
                if let idx = showVolumeForSlugs.firstIndex(of: sound.slug) {
                    showVolumeForSlugs.remove(at: idx)
                    audioManager.stop(for: sound.id)
                    if showVolumeForSlugs.isEmpty {
                        isPlayingAll = false
                    }
                } else {
                    showVolumeForSlugs.append(sound.slug)
                    if volumes[sound.slug] == nil {
                        volumes[sound.slug] = 0.5
                    }
                    // Play just this sound while keeping others playing
                    if isPlayingAll {
                        let activeSounds = selectedCustomSounds.filter { (volumes[$0.slug] ?? 0.5) > 0 }
                        audioManager.play(sounds: activeSounds)
                        audioManager.setVolume(for: sound.id, volume: volumes[sound.slug] ?? 0.5)
                    }
                }
            }) {
                VStack {
                    AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(sound.avatar)")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 3)
                                    .opacity(showVolumeForSlugs.contains(sound.slug) ? 1 : 0)
                            )
                    } placeholder: {
                        ProgressView()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                    Text(sound.title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .buttonStyle(PlainButtonStyle())

            VStack {
                if showVolumeForSlugs.contains(sound.slug) {
                    Slider(
                        value: Binding(
                            get: { volumes[sound.slug] ?? 0.5 },
                            set: { newValue in
                                volumes[sound.slug] = newValue
                                audioManager.setVolume(for: sound.id, volume: newValue)
                            }
                        ),
                        in: 0...1
                    )
                    .accentColor(.white)
                    .transition(.opacity)
                }
            }
            .frame(height: 30)
            .padding(.horizontal, 20)
        }
        .frame(height: 120)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                ScrollView {
                    Text("Custom Sounds")
                        .bold()
                        .foregroundColor(.white)
                        .padding(10)
                    VStack(alignment: .leading) {
                        ForEach(groupedSounds, id: \.0) { category, sounds in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Category: \(category)")
                                    .font(.headline)
                                    .padding(.leading, 8)
                                    .foregroundColor(.white)
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(sounds) { sound in
                                        soundCell(for: sound)
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    
                    if !showVolumeForSlugs.isEmpty {
                        Spacer()
                            .frame(height: 80)
                    }
                }
            }
            
            if !showVolumeForSlugs.isEmpty {
                BottomPopupView(
                    showMixSound: $showMixSound,
                    deviceVolume: deviceVolume,
                    soundCount: showVolumeForSlugs.count,
                    isPlayingAll: isPlayingAll,
                    onPlayPauseAll: {
                        if isPlayingAll {
                            audioManager.stopAll()
                        } else {
                            let selectedSounds = selectedCustomSounds
                            audioManager.play(sounds: selectedSounds)
                            for sound in selectedSounds {
                                audioManager.setVolume(for: sound.id, volume: volumes[sound.slug] ?? 0.5)
                            }
                        }
                        isPlayingAll.toggle()
                    },
                    onTimer: { showSetTimer = true }
                )
                .environmentObject(timerManager)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showVolumeForSlugs.count)
            }
        }
        .sheet(isPresented: $showSetTimer) {
            SetTimerView(isPresented: $showSetTimer, selectedTimer: $selectedTimer)
                .environmentObject(timerManager)
                .presentationDetents([.fraction(0.65)])
        }
        .sheet(isPresented: $showMixSound) {
            MixSoundView(
                selectedSounds: Binding(
                    get: {
                        // Truyền selectedCustomSounds với volume từ volumes dictionary
                        selectedCustomSounds.map { sound in
                            var soundWithVolume = sound
                            soundWithVolume.volume = String(volumes[sound.slug] ?? 0.5)
                            return soundWithVolume
                        }
                    },
                    set: { newValue in
                        showVolumeForSlugs = newValue.map { $0.slug }
                        // Cập nhật volumes dictionary từ newValue
                        for sound in newValue {
                            if let volume = sound.volume {
                                volumes[sound.slug] = Float(volume) ?? 0.5
                            }
                        }
                    }
                ),
                audioManager: audioManager,
                deviceVolume: deviceVolume
            )
        }
    }

    private func toggleSound(_ sound: CustomSoundData) {
        if let index = selectedSounds.firstIndex(where: { $0.id == sound.id }) {
            selectedSounds.remove(at: index)
        } else {
            selectedSounds.append(sound)
        }
    }
}

class MockSoundDataViewModel: SoundDataViewModel {
    override init() {
        super.init()
        sounds = [
            CustomSoundData(
                id: 1,
                linkMusic: "Light Rain",
                avatar: "bgApp",
                title: "Rain",
                slug: "https://example.com/light_rain.mp3",
                category: "light-rain",
                toggleUrl: "",
                url: "",
                country: "VN",
                status: 1,
                createdAt: "2024-01-01T00:00:00Z",
                updatedAt: "2024-01-01T00:00:00Z"
            ),
            CustomSoundData(
                id: 2,
                linkMusic: "Heavy Rain",
                avatar: "bgApp",
                title: "Rain",
                slug: "https://example.com/heavy_rain.mp3",
                category: "heavy-rain",
                toggleUrl: "",
                url: "",
                country: "VN",
                status: 1,
                createdAt: "2024-01-01T00:00:00Z",
                updatedAt: "2024-01-01T00:00:00Z"
            ),
            CustomSoundData(
                id: 1,
                linkMusic: "Heavy Rain",
                avatar: "bgApp",
                title: "Rain",
                slug: "https://example.com/heavy_rain2.mp3",
                category: "heavy-rain",
                toggleUrl: "",
                url: "",
                country: "VN",
                status: 1,
                createdAt: "2024-01-01T00:00:00Z",
                updatedAt: "2024-01-01T00:00:00Z"
            ), CustomSoundData(
                id: 2,
                linkMusic: "Heavy Rain",
                avatar: "bgApp",
                title: "Rain",
                slug: "https://example.com/heavy_rain3.mp3",
                category: "heavy-rain",
                toggleUrl: "",
                url: "",
                country: "VN",
                status: 1,
                createdAt: "2024-01-01T00:00:00Z",
                updatedAt: "2024-01-01T00:00:00Z"
            ),
        ]
        isLoading = false
        errorMessage = nil
    }
}

#if DEBUG
    struct CustomSoundView_Previews: PreviewProvider {
        static var previews: some View {
            let mockViewModel = MockSoundDataViewModel()
            return CustomGridSoundView(viewModel: mockViewModel)
                .background(Color.black)
                .previewLayout(.sizeThatFits)
        }
    }
#endif
