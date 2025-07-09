//
//  SoundModel.swift
//  RelaxSounds
//
//  Created by MacMini A6 on 25/6/25.
//

import Foundation

struct SoundModel: Identifiable, Codable, Hashable {
    let id: Int
    let avatar: String
    let title: String
    let slug: String
    let status: Int
    let createdAt: String
    let updatedAt: String
    let defaultSoundURL: String?
    let defaultVolume: Float?
    
    // Computed property to maintain compatibility with existing code
    var name: String {
        return title
    }
    
    // Computed property to maintain compatibility with existing code
    var imageName: String {
        return avatar
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatar
        case title
        case slug
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case defaultSoundURL = "default_sound_url"
        case defaultVolume = "default_volume"
    }
    
    init(id: Int, avatar: String, title: String, slug: String, status: Int, createdAt: String, updatedAt: String, defaultSoundURL: String? = nil, defaultVolume: Float? = nil) {
        self.id = id
        self.avatar = avatar
        self.title = title
        self.slug = slug
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.defaultSoundURL = defaultSoundURL
        self.defaultVolume = defaultVolume ?? 0.5
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SoundModel, rhs: SoundModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// API Response structure
struct SoundResponse: Codable {
    let status: Bool
    let data: SoundData
}

struct SoundData: Codable {
    let currentPage: Int
    let data: [SoundModel]
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
    }
}
