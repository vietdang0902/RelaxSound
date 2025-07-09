//
//  SoundViewViewModel.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 26/6/25.
//

import Foundation

class SoundViewModel: ObservableObject {
    @Published var sounds: [SoundModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var customSounds: [SoundModel] = []
    @Published var mixedSounds: [MixedSoundModel] = []
    
    func loadSounds() {
        isLoading = true
        errorMessage = nil
        fetchSoundsFromAPI()
    }
    
    func fetchSoundsFromAPI() {
        guard let url = URL(string: "https://sleepchills.kenhtao.site/api/v1/categories?page=1") else {
            self.errorMessage = "URL không hợp lệ"
            self.isLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else {
                    self?.errorMessage = "Không nhận được dữ liệu"
                    return
                }
                do {
                    let response = try JSONDecoder().decode(SoundResponse.self, from: data)
                    self?.sounds = response.data.data
                } catch {
                    self?.errorMessage = "Lỗi decode dữ liệu: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func play(sound: SoundModel) {
        print("Play: \(sound.title)")
    }
    
    func saveCustomSound(title: String, avatar: String) {
        let newSound = SoundModel(
            id: customSounds.count + 1000, // Dùng id từ 1000 trở lên để tránh trùng với sounds từ API
            avatar: avatar,
            title: title,
            slug: title.lowercased().replacingOccurrences(of: " ", with: "-"),
            status: 1,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        customSounds.append(newSound)
        saveCustomSoundsToStorage()
    }
    
    private func saveCustomSoundsToStorage() {
        if let encoded = try? JSONEncoder().encode(customSounds) {
            UserDefaults.standard.set(encoded, forKey: "CustomSounds")
        }
    }
    
    func loadCustomSounds() {
        if let data = UserDefaults.standard.data(forKey: "CustomSounds"),
           let decoded = try? JSONDecoder().decode([SoundModel].self, from: data) {
            customSounds = decoded
        }
    }
    
    func loadMixedSounds() {
        if let data = UserDefaults.standard.data(forKey: "MixedSounds"),
           let decoded = try? JSONDecoder().decode([MixedSoundModel].self, from: data) {
            mixedSounds = decoded
        }
    }
    
    func saveMixedSound(title: String, avatar: String, mixedSounds: [MixedSound]) {
        // Load existing mixedSounds from UserDefaults first
        loadMixedSounds()
        
        // Generate new ID based on existing data
        let newId = (self.mixedSounds.map { $0.id }.max() ?? 0) + 1
        
        let newMixedSound = MixedSoundModel(
            id: newId,
            title: title,
            avatar: avatar,
            mixedSounds: mixedSounds,
            createdAt: Date()
        )
        self.mixedSounds.append(newMixedSound)
        saveMixedSoundsToStorage()
    }
    
    private func saveMixedSoundsToStorage() {
        if let encoded = try? JSONEncoder().encode(mixedSounds) {
            UserDefaults.standard.set(encoded, forKey: "MixedSounds")
        }
    }
    
    func deleteMixedSound(id: Int) {
        mixedSounds.removeAll { $0.id == id }
        saveMixedSoundsToStorage()
    }
    
    func updateMixedSound(id: Int, title: String, avatar: String) {
        // Load existing mixedSounds from UserDefaults first
        loadMixedSounds()
        
        // Find and update the mixedSound
        if let index = mixedSounds.firstIndex(where: { $0.id == id }) {
            let updatedMixedSound = MixedSoundModel(
                id: mixedSounds[index].id,
                title: title,
                avatar: avatar,
                mixedSounds: mixedSounds[index].mixedSounds,
                createdAt: mixedSounds[index].createdAt
            )
            mixedSounds[index] = updatedMixedSound
            saveMixedSoundsToStorage()
        }
    }
}
