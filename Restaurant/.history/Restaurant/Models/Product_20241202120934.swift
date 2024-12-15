import Foundation

struct Product: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?
    let price: Double
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "product_id"
        case name
        case description
        case price
        case imageUrl = "image_url"
    }
} 