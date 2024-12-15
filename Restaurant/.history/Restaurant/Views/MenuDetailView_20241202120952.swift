import SwiftUI

struct MenuDetailView: View {
    @StateObject private var viewModel: MenuDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(product: Product) {
        _viewModel = StateObject(wrappedValue: MenuDetailViewModel(product: product))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image
                if let imageUrl = viewModel.product.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 300)
                    .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 300)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Product Name and Price
                    HStack {
                        Text(viewModel.product.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", viewModel.product.price))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    // Description
                    if let description = viewModel.product.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quantity Selector
                    HStack {
                        Text("Quantity")
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.decrementQuantity()
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(viewModel.quantity <= 1)
                            
                            Text("\(viewModel.quantity)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(minWidth: 40)
                            
                            Button(action: {
                                viewModel.incrementQuantity()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    // Add to Cart Button
                    Button(action: {
                        Task {
                            await viewModel.addToCart()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Add to Cart")
                                    .fontWeight(.semibold)
                                Image(systemName: "cart.badge.plus")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
        .alert("Success", isPresented: $viewModel.showSuccessMessage) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Item added to cart successfully!")
        }
    }
} 