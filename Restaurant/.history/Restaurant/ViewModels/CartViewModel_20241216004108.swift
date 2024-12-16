import Foundation
import PassKit

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var showCheckoutSuccess = false
    
    var total: Double {
        cartItems.reduce(0) { sum, item in
            sum + (Double(item.quantity) * item.priceAsDouble)
        }
    }
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        if let formattedString = formatter.string(from: NSNumber(value: total)) {
            return "Rp \(formattedString)"
        }
        return "Rp 0"
    }
    
    private let networkManager = NetworkManager.shared
    
    func fetchCart() async {
        isLoading = true
        error = nil
        
        do {
            cartItems = try await networkManager.fetchCart()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func removeItem(_ item: CartItem) async {
        isLoading = true
        error = nil
        
        do {
            try await networkManager.removeFromCart(productId: item.productId)
            if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                cartItems.remove(at: index)
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    
    func updateQuantity(for item: CartItem, newQuantity: Int) async {
        guard newQuantity > 0 else { return }
        
        do {
            try await networkManager.updateCartQuantity(productId: item.productId, quantity: newQuantity)
            
            if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                let updatedItem = CartItem(productId: item.productId, name: item.name, price: item.price, quantity: newQuantity)
                cartItems[index] = updatedItem
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}

