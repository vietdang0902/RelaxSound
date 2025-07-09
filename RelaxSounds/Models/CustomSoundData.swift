import Foundation

struct CustomSoundData: Identifiable, Codable, Equatable {
    let id: Int
    let linkMusic: String
    let avatar: String
    let title: String
    let slug: String
    let category: String
    let toggleUrl: String?
    let url: String?
    let country: String
    let status: Int
    let createdAt: String
    let updatedAt: String
    var volume: String?

    var countryList: [String] {
        (try? JSONDecoder().decode([String].self, from: Data(country.utf8))) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case id
        case linkMusic = "link_music"
        case avatar
        case title
        case slug
        case category
        case toggleUrl = "toggle_url"
        case url
        case country
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case volume
    }
    
    static func == (lhs: CustomSoundData, rhs: CustomSoundData) -> Bool {
        return lhs.id == rhs.id
    }
}
