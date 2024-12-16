import Foundation

struct CartItem: Identifiable, Codable {
    let productId: Int
    let name: String
    let price: String
    let quantity: Int
    let imageUrl: String?
    
    var id: String { name }
    
    var priceAsDouble: Double {
        if let price = Double(price) {
            return price
        }
        return 0.0
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        if let price = Double(price),
           let formattedString = formatter.string(from: NSNumber(value: price)) {
            return "Rp \(formattedString)"
        }
        return "Rp 0"
    }
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case name
        case price
        case quantity
        case imageUrl = "image_url"
    }
} 
