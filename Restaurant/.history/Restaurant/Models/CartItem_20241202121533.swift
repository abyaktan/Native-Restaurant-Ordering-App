import Foundation

struct CartItem: Identifiable, Codable {
    let id: Int
    let userId: Int
    let productId: Int
    var quantity: Int
    var product: Product?
    
    enum CodingKeys: String, CodingKey {
        case id = "cart_id"
        case userId = "user_id"
        case productId = "product_id"
        case quantity
        case product
    }
} 