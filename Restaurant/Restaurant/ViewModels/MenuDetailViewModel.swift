import Foundation

@MainActor
class MenuDetailViewModel: ObservableObject {
    @Published var quantity = 1
    @Published var isLoading = false
    @Published var error: String?
    @Published var showSuccessMessage = false
    
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    func addToCart() async {
        isLoading = true
        error = nil
        
        do {
            try await NetworkManager.shared.addToCart(productId: product.id, quantity: quantity)
            showSuccessMessage = true
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func incrementQuantity() {
        quantity += 1
    }
    
    func decrementQuantity() {
        guard quantity > 1 else { return }
        quantity -= 1
    }
} 