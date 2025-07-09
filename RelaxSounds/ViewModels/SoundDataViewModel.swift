//
//  SoundDataViewModel.swift
//  RelaxSounds
//
//  Created by VietMac on 1/7/25.
//

import Foundation
import Combine

class SoundDataViewModel: ObservableObject {
    @Published var sounds: [CustomSoundData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    func fetchSounds() {
        guard let url = URL(string: "https://sleepchills.kenhtao.site/api/v1/music?page=1") else {
            self.errorMessage = "Invalid URL"
            return
        }
        isLoading = true
        errorMessage = nil
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .map { $0.data.data }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] sounds in
                self?.sounds = sounds
            })
            .store(in: &cancellables)
    }
}

// MARK: - API Response Models
struct APIResponse: Codable {
    let status: Bool
    let data: MusicDataPage
    let message: String?
}

struct MusicDataPage: Codable {
    let current_page: Int
    let data: [CustomSoundData]
    // ... các trường khác nếu cần
}
