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
    
    // func incrementQuantity(for item: CartItem) async {
    //     let newQuantity = item.quantity + 1
    //     await updateQuantity(for: item, newQuantity: newQuantity)
    // }
    
    // func decrementQuantity(for item: CartItem) async {
    //     guard item.quantity > 1 else { return }
    //     let newQuantity = item.quantity - 1
    //     await updateQuantity(for: item, newQuantity: newQuantity)
    // }
    
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

