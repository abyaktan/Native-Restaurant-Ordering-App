import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Create Account")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 20) {
                    // Username field
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    // Password field
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Verify Password field
                    SecureField("Verify Password", text: $viewModel.verifyPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Password requirements
                    if !viewModel.password.isEmpty {
                        HStack {
                            Image(systemName: viewModel.isPasswordValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.isPasswordValid ? .green : .red)
                            Text("Password must be at least 8 characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Password match indicator
                    if !viewModel.verifyPassword.isEmpty {
                        HStack {
                            Image(systemName: viewModel.passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.passwordsMatch ? .green : .red)
                            Text("Passwords must match")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Register button
                    Button(action: {
                        Task {
                            await viewModel.register()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Register")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    
                    // Back to login button
                    Button("Already have an account? Login") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                .padding(.top, 30)
                
                // Error message
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .onChange(of: viewModel.registrationSuccess) { success in
            if success {
                dismiss()
            }
        }
    }
}