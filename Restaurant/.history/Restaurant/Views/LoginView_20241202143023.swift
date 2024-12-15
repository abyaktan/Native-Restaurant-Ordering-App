import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.black : Color.white,
                        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Logo or App Title
                        Text("Restaurant")
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
                            
                            // Login button
                            Button(action: {
                                Task {
                                    await viewModel.login()
                                }
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Login")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .disabled(viewModel.isLoading)
                            
                            // Biometric login button
                            if viewModel.showBiometricLogin {
                                Button(action: {
                                    Task {
                                        await viewModel.authenticateWithBiometrics()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: LAContext().biometryType == .faceID ? "faceid" : "touchid")
                                        Text("Login with Biometrics")
                                    }
                                }
                                .disabled(viewModel.isLoading)
                            }
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
            }
            .navigationBarHidden(true)
        }
    }
} 
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}