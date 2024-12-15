import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        }
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func fetchProducts() async {
        isLoading = true
        error = nil
        
        do {
            products = try await NetworkManager.shared.fetchProducts()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}
