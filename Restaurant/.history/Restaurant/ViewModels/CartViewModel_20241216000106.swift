import Foundation

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
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
            // Remove locally first for better UX
            if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                cartItems.remove(at: index)
            }
            
            // Then update server
            try await networkManager.removeFromCart(name: item.name)
        } catch {
            // Refresh the cart if the server update fails
            await fetchCart()
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateQuantity(for item: CartItem, newQuantity: Int) async {
        guard newQuantity > 0 else { return }
        
        do {
            // Update locally first for better UX
            if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                var updatedItem = item
                updatedItem = CartItem(name: item.name, price: item.price, quantity: newQuantity)
                cartItems[index] = updatedItem
            }
            
            // Then update server
            try await networkManager.updateCartQuantity(name: item.name, quantity: newQuantity)
        } catch {
            // Refresh the cart if the server update fails
            await fetchCart()
            self.error = error.localizedDescription
        }
    }
}

