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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        
        // Handle price as string and convert to Double
        let priceString = try container.decode(String.self, forKey: .price)
        if let priceDouble = Double(priceString) {
            price = priceDouble
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .price,
                in: container,
                debugDescription: "Price must be a valid number string"
            )
        }
    }
} 
