import Foundation

struct MixedSound: Codable, Hashable {
    let soundId: Int
    let volume: Double
}

struct MixedSoundModel: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let avatar: String
    let mixedSounds: [MixedSound]
    let createdAt: Date
    
    var name: String {
        return title
    }
    
    var imageName: String {
        return avatar
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MixedSoundModel, rhs: MixedSoundModel) -> Bool {
        return lhs.id == rhs.id
    }
}
