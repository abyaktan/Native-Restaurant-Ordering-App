import Foundation

struct CartItem: Identifiable, Codable {
    let productId: Int
    let name: String
    let price: String
    let quantity: Int
    
    var id: String { name }
    
    var priceAsDouble: Double {
        if let price = Double(price) {
            return price
        }
        return 0.0
    }
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case name
        case price
        case quantity
    }
} 
