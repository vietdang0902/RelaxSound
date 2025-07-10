import AVFoundation
import Combine

class AudioManager: ObservableObject {
    private var engine = AVAudioEngine()
    private var playerNodes: [Int: AVAudioPlayerNode] = [:]
    private var audioFiles: [Int: AVAudioFile] = [:]
    private var buffers: [Int: AVAudioPCMBuffer] = [:]

    @Published var playingSoundIDs: Set<Int> = []
    @Published var currentMusicTitle: String = ""
    @Published var isPlaying: Bool = false

    var hasAudioLoaded: Bool {
        return !playerNodes.isEmpty
    }

    init() {
        setupAudioSession()
        setupEngine()
    }
    
    private func setupEngine() {
            engine = AVAudioEngine()
        }

    func play(sounds: [CustomSoundData]) {
        stopAll()
        isPlaying = true
        for sound in sounds {
            guard let url = URL(string: sound.linkMusic) else { continue }
            let id = sound.id
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            let volume = Float(sound.volume ?? "0.5") ?? 0.5
            let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
            engine.connect(playerNode, to: engine.mainMixerNode, format: outputFormat)
            playerNode.volume = volume
            playerNodes[id] = playerNode

            downloadAudio(url: url) { [weak self] file in
                guard let self = self, let file = file else { return }
                self.audioFiles[id] = file
                if let buffer = self.createBuffer(from: file) {
                    self.buffers[id] = buffer
                    playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                    if !self.engine.isRunning {
                        try? self.engine.start()
                    }
                    playerNode.play()
                }
            }
        }
    }

    func playMixedSounds(_ mixedSound: MixedSoundModel) {
        stopAll()
        isPlaying = true
        for component in mixedSound.mixedSounds {
            // Sử dụng trực tiếp linkMusic từ component, không cần lookup API
            guard let url = URL(string: component.linkMusic) else {
                print("Invalid URL for soundId \(component.soundId): \(component.linkMusic)")
                continue
            }
            let id = component.soundId
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            let volume = Float(component.volume / 100.0) // Chuyển volume từ 0-100 về 0-1
            let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
            engine.connect(playerNode, to: engine.mainMixerNode, format: outputFormat)
            playerNode.volume = volume
            playerNodes[id] = playerNode

            downloadAudio(url: url) { [weak self] file in
                guard let self = self, let file = file else { return }
                self.audioFiles[id] = file
                if let buffer = self.createBuffer(from: file) {
                    self.buffers[id] = buffer
                    playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                    if !self.engine.isRunning {
                        try? self.engine.start()
                    }
                    playerNode.play()
                    DispatchQueue.main.async {
                        self.playingSoundIDs.insert(id)
                    }
                }
            }
        }
    }

    func addSoundToMix(_ sound: MixedSound) {
        guard let url = URL(string: sound.linkMusic) else {
            print("Invalid URL for sound: \(sound.linkMusic)")
            return
        }
        let id = sound.soundId

        if playerNodes[id] != nil {
            print("Sound \(id) is already in the engine.")
            return
        }

        let playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        let volume = Float(sound.volume / 100.0)
        let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(playerNode, to: engine.mainMixerNode, format: outputFormat)
        playerNode.volume = volume
        playerNodes[id] = playerNode

        downloadAudio(url: url) { [weak self] file in
            guard let self = self, let file = file else { return }
            self.audioFiles[id] = file
            if let buffer = self.createBuffer(from: file) {
                self.buffers[id] = buffer
                playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                if !self.engine.isRunning {
                    try? self.engine.start()
                }
                playerNode.play()
                DispatchQueue.main.async {
                    self.playingSoundIDs.insert(id)
                }
            }
        }
    }
    
    func playWithMainSound(_ mainSound: SoundModel, customSounds: [CustomSoundData]) {
        stopAll()
        isPlaying = true
        
        // Determine category from the main sound title/slug
        let soundCategory = determineCategoryFromSound(mainSound)
        
        // Fetch music from API with category filter
        fetchMusicFromAPI(category: soundCategory) { [weak self] musicURL in
            guard let self = self, let musicURL = musicURL else {
                print("Failed to fetch music URL from API")
                return
            }
            
            print("Playing main sound from URL: \(musicURL)")
            let mainId = mainSound.id
            let mainPlayerNode = AVAudioPlayerNode()
            self.engine.attach(mainPlayerNode)
            let mainVolume: Float = 0.5
            let outputFormat = self.engine.mainMixerNode.outputFormat(forBus: 0)
            self.engine.connect(mainPlayerNode, to: self.engine.mainMixerNode, format: outputFormat)
            mainPlayerNode.volume = mainVolume
            self.playerNodes[mainId] = mainPlayerNode
            
            self.downloadAudio(url: musicURL) { [weak self] file in
                guard let self = self, let file = file else {
                    print("Failed to download main sound audio")
                    return
                }
                print("Successfully downloaded main sound")
                self.audioFiles[mainId] = file
                if let buffer = self.createBuffer(from: file) {
                    self.buffers[mainId] = buffer
                    mainPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                    if !self.engine.isRunning {
                        try? self.engine.start()
                    }
                    mainPlayerNode.play()
                    print("Main sound started playing")
                }
            }
        }
        
        // Play custom sounds
        for sound in customSounds {
            guard let url = URL(string: sound.linkMusic) else { continue }
            let id = sound.id
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            let volume = Float(sound.volume ?? "0.5") ?? 0.5
            let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
            engine.connect(playerNode, to: engine.mainMixerNode, format: outputFormat)
            playerNode.volume = volume
            playerNodes[id] = playerNode

            downloadAudio(url: url) { [weak self] file in
                guard let self = self, let file = file else { return }
                self.audioFiles[id] = file
                if let buffer = self.createBuffer(from: file) {
                    self.buffers[id] = buffer
                    playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                    if !self.engine.isRunning {
                        try? self.engine.start()
                    }
                    playerNode.play()
                }
            }
        }
    }
    
    func addCustomSound(_ customSound: CustomSoundData) {
        guard let url = URL(string: customSound.linkMusic) else {
            print("Invalid URL for custom sound: \(customSound.linkMusic)")
            return
        }
        let id = customSound.id
        
        // Kiểm tra xem sound này đã được phát chưa
        if playerNodes[id] != nil {
            print("Custom sound \(id) is already playing")
            return // Đã được phát rồi
        }
        
        print("Adding custom sound: \(customSound.title) with ID: \(id)")
        
        let playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        let volume = Float(customSound.volume ?? "0.5") ?? 0.5
        let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(playerNode, to: engine.mainMixerNode, format: outputFormat)
        playerNode.volume = volume
        playerNodes[id] = playerNode

        downloadAudio(url: url) { [weak self] file in
            guard let self = self, let file = file else {
                print("Failed to download custom sound audio")
                return
            }
            print("Successfully downloaded custom sound")
            self.audioFiles[id] = file
            if let buffer = self.createBuffer(from: file) {
                self.buffers[id] = buffer
                playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                if !self.engine.isRunning {
                    try? self.engine.start()
                }
                // Chỉ phát nếu đang trong trạng thái playing
                if self.isPlaying {
                    playerNode.play()
                    print("Started playing custom sound: \(customSound.title)")
                } else {
                    print("Engine not playing, custom sound loaded but not started")
                }
            }
        }
    }

    func setVolume(for id: Int, volume: Float) {
        playerNodes[id]?.volume = volume
    }
    
    func pause() {
        for node in playerNodes.values {
            node.pause()
        }
        isPlaying = false
    }
    
    func resume() {
        for node in playerNodes.values {
            node.play()
        }
        isPlaying = true
    }

    func stopAll() {
        for node in playerNodes.values {
            node.stop()
            engine.detach(node)
        }
        playerNodes.removeAll()
        audioFiles.removeAll()
        buffers.removeAll()
        if engine.isRunning {
            engine.stop()
        }
        isPlaying = false
        
        DispatchQueue.main.async {
            self.playingSoundIDs.removeAll()
            self.currentMusicTitle = ""
        }
    }

    func stop(for id: Int) {
        print("Stopping sound with id: \(id)")
        if let node = playerNodes[id] {
            node.stop()
            engine.detach(node)
            playerNodes.removeValue(forKey: id)
            audioFiles.removeValue(forKey: id)
            buffers.removeValue(forKey: id)
            DispatchQueue.main.async {
                self.playingSoundIDs.remove(id)
            }
        }
    }

    private func downloadAudio(url: URL, completion: @escaping (AVAudioFile?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, _, _ in
            guard let localURL = localURL else { completion(nil); return }
            do {
                let file = try AVAudioFile(forReading: localURL)
                completion(file)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

    private func createBuffer(from file: AVAudioFile) -> AVAudioPCMBuffer? {
        let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else { return nil }
        do {
            try file.read(into: buffer)
            // If channel counts match, return as is
            if buffer.format.channelCount == outputFormat.channelCount {
                return buffer
            }
            // Convert buffer to match output format
            guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: buffer.frameCapacity) else { return nil }
            let converter = AVAudioConverter(from: buffer.format, to: outputFormat)!
            var error: NSError?
            let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }
            converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)
            return convertedBuffer
        } catch {
            return nil
        }
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    private func fetchMusicFromAPI(category: String, completion: @escaping (URL?) -> Void) {
        guard let apiURL = URL(string: "https://sleepchills.kenhtao.site/api/v1/music?page=1") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: apiURL) { data, response, error in
            guard let data = data, error == nil else {
                print("API request failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseData = json["data"] as? [String: Any],
                   let musicArray = responseData["data"] as? [[String: Any]] {
                    
                    // Filter by category first - THỰC SỰ LỌC THEO CATEGORY
                    var selectedMusic: [String: Any]?
                    
                    selectedMusic = musicArray.first { music in
                        if let musicCategory = music["category"] as? String {
                            return musicCategory.lowercased() == category.lowercased()
                        }
                        return false
                    }
                    
                    // Fallback to first music if no category match
                    if selectedMusic == nil {
                        selectedMusic = musicArray.first
                        print("No match found for category '\(category)', using fallback")
                    }
                    
                    if let music = selectedMusic,
                       let linkMusic = music["link_music"] as? String,
                       let musicURL = URL(string: linkMusic),
                       let musicTitle = music["title"] as? String {
                        print("Found music '\(musicTitle)' for category '\(category)': \(musicURL)")
                        
                        // Lưu title của music vào thuộc tính
                        DispatchQueue.main.async {
                            self.currentMusicTitle = musicTitle
                        }
                        
                        completion(musicURL)
                    } else {
                        print("Failed to find music for category: \(category)")
                        completion(nil)
                    }
                } else {
                    print("Failed to parse API response")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    private func determineCategoryFromSound(_ sound: SoundModel) -> String {
        let title = sound.title.lowercased()
        let slug = sound.slug.lowercased()
        
        print("Determining category for sound: '\(sound.title)' with slug: '\(sound.slug)'")
        
        // Map sound to appropriate category based on title/slug
        if title.contains("cafe") || title.contains("coffee") || slug.contains("cafe") || title.contains("chill") {
            print("Detected category: Cafe")
            return "Cafe"
        } else if title.contains("rain") || title.contains("drizzle") || title.contains("thunder") || slug.contains("rain") {
            print("Detected category: Rain")
            return "Rain"
        } else if title.contains("bird") || title.contains("cow") || title.contains("dog") || title.contains("cat") || title.contains("horse") || title.contains("frog") || title.contains("cricket") || title.contains("owl") || slug.contains("bird") || slug.contains("animal") {
            print("Detected category: Animal")
            return "Animal"
        } else if title.contains("ocean") || title.contains("wave") || title.contains("sea") || title.contains("tide") || slug.contains("ocean") || slug.contains("wave") {
            print("Detected category: Ocean")
            return "Ocean"
        } else if title.contains("fire") || title.contains("flame") || title.contains("burn") || slug.contains("fire") {
            print("Detected category: Fire")
            return "Fire"
        } else if title.contains("forest") || title.contains("tree") || title.contains("wood") || slug.contains("forest") {
            print("Detected category: Forest")
            return "Forest"
        } else if title.contains("city") || title.contains("traffic") || title.contains("urban") || title.contains("street") || title.contains("car") || title.contains("train") || title.contains("subway") || slug.contains("city") || slug.contains("traffic") {
            print("Detected category: City")
            return "City"
        } else if title.contains("farm") || slug.contains("farm") {
            print("Detected category: Farm")
            return "Farm"
        } else if title.contains("lake") || title.contains("water") || slug.contains("lake") {
            print("Detected category: Lake")
            return "Lake"
        } else if title.contains("cave") || slug.contains("cave") {
            print("Detected category: Cave")
            return "Cave"
        } else if title.contains("desert") || slug.contains("desert") {
            print("Detected category: Desert")
            return "Desert"
        } else if title.contains("night") || slug.contains("night") {
            print("Detected category: Night")
            return "Night"
        } else if title.contains("piano") || title.contains("guitar") || title.contains("violin") || title.contains("harp") || title.contains("flute") || title.contains("saxophone") || title.contains("trumpet") || title.contains("drum") || slug.contains("music") {
            print("Detected category: Musical Instrument")
            return "Musical Instrument"
        } else if title.contains("airplane") || title.contains("airport") || slug.contains("air") {
            print("Detected category: Air Travel")
            return "Air Travel"
        } else if title.contains("underwater") || title.contains("dolphin") || title.contains("fish") {
            print("Detected category: Under Water")
            return "Under Water"
        } else if title.contains("waterfall") || slug.contains("waterfall") {
            print("Detected category: Water Fall")
            return "Water Fall"
        } else {
            print("No specific category detected, using default: Cafe")
            return "Cafe"
        }
    }
}
