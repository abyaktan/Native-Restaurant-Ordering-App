import Foundation

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var showCheckoutSuccess = false
    
    var total: Double {
        cartItems.reduce(0) { sum, item in
            sum + (Double(item.quantity) * (item.product?.price ?? 0))
        }
    }
    
    func fetchCart() async {
        isLoading = true
        error = nil
        
        do {
            cartItems = try await NetworkManager.shared.fetchCart()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func checkout() async {
        isLoading = true
        error = nil
        
        // Simulate checkout process
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds delay
        
        showCheckoutSuccess = true
        cartItems = []
        
        isLoading = false
    }
    
    func removeItem(_ item: CartItem) async {
        // Add API call to remove item from cart
        // For now, just remove locally
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems.remove(at: index)
        }
    }
    
    func updateQuantity(for item: CartItem, newQuantity: Int) async {
        // Add API call to update quantity
        // For now, just update locally
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].quantity = newQuantity
        }
    }
} 