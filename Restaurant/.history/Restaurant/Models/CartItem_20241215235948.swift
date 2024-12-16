import Foundation

struct CartItem: Identifiable, Codable {
    let name: String
    let price: String
    let quantity: Int
    
    var id: String { name }
    
    var priceAsDouble: Double {
        Double(price) ?? 0.0
    }
} 
