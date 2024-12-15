import Foundation
import PassKit

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var showCheckoutSuccess = false
    @Published var showPaymentOptions = false
    @Published var selectedPaymentMethod: PaymentMethod?
    
    enum PaymentMethod: String, CaseIterable {
        case applePay = "Apple Pay"
        case creditCard = "Credit Card"
        case paypal = "PayPal"
    }
    
    var total: Double {
        cartItems.reduce(0) { sum, item in
            sum + (Double(item.quantity) * (item.product?.price ?? 0))
        }
    }
    
    private let networkManager = NetworkManager.shared
    private var paymentController: PKPaymentAuthorizationController?
    
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
        isLoading = true
        error = nil
        
        do {
            try await networkManager.updateCartQuantity(productId: item.productId, quantity: newQuantity)
            if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                cartItems[index].quantity = newQuantity
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func initiatePayment(method: PaymentMethod) async {
        isLoading = true
        error = nil
        
        switch method {
        case .applePay:
            await processApplePayPayment()
        case .creditCard:
            await processCreditCardPayment()
        case .paypal:
            await processPayPalPayment()
        }
    }
    
    private func processApplePayPayment() async {
        guard PKPaymentAuthorizationController.canMakePayments() else {
            error = "Apple Pay is not available"
            isLoading = false
            return
        }
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.yourapp.restaurant" // Replace with your merchant ID
        request.countryCode = "ID"
        request.currencyCode = "IDR"
        request.supportedNetworks = [.masterCard, .visa]
        request.merchantCapabilities = .capability3DS
        
        let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: total))
        request.paymentSummaryItems = [total]
        
        paymentController = PKPaymentAuthorizationController(paymentRequest: request)
        paymentController?.delegate = self
        
        if let controller = paymentController {
            let success = await controller.present()
            if !success {
                error = "Failed to present Apple Pay"
                isLoading = false
            }
        }
    }
    
    private func processCreditCardPayment() async {
        // Simulate credit card processing
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        await completePayment()
    }
    
    private func processPayPalPayment() async {
        // Simulate PayPal processing
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        await completePayment()
    }
    
    private func completePayment() async {
        do {
            // Here you would typically make an API call to your backend
            // to process the payment and clear the cart
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            cartItems = []
            showCheckoutSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

extension CartViewModel: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                      didAuthorizePayment payment: PKPayment,
                                      handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Process the payment with your payment provider
        Task {
            await completePayment()
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            self.paymentController = nil
        }
    }
} 
} 