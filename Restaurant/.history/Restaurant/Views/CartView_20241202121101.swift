import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.cartItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Your cart is empty")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.cartItems) { item in
                            CartItemRow(item: item, onQuantityChange: { newQuantity in
                                Task {
                                    await viewModel.updateQuantity(for: item, newQuantity: newQuantity)
                                }
                            }, onRemove: {
                                Task {
                                    await viewModel.removeItem(item)
                                }
                            })
                        }
                        
                        VStack(spacing: 16) {
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", viewModel.total))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Button(action: {
                                Task {
                                    await viewModel.checkout()
                                }
                            }) {
                                Text("Checkout")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Cart")
        .task {
            await viewModel.fetchCart()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
        .alert("Success", isPresented: $viewModel.showCheckoutSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your order has been placed successfully!")
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageUrl = item.product?.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product?.name ?? "")
                    .font(.headline)
                
                Text("$\(String(format: "%.2f", item.product?.price ?? 0))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Stepper(
                    "Quantity: \(item.quantity)",
                    value: Binding(
                        get: { item.quantity },
                        set: { onQuantityChange($0) }
                    ),
                    in: 1...99
                )
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
} 