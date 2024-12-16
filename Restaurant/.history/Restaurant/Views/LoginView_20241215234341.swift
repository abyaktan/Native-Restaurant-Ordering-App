import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 25) {
                        Spacer()
                            .frame(height: geometry.size.height * 0.1)
                        
                        // Logo
                        Image("Logo") // Add this image to your assets
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .padding(.bottom, 20)
                        
                        // App Title
//                        Text("Saung Simbok")
//                            .font(.system(size: 40, weight: .bold))
//                            .foregroundColor(.primary)
                        
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
                            
                            // Register button
                            NavigationLink(destination: RegistrationView()) {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.secondary.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 30)
                        
                        // Error message
                        if let error = viewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.black : Color.white,
                        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                viewModel.loginSuccess = true
            }
        }
        .fullScreenCover(isPresented: $viewModel.loginSuccess) {
            HomeView()
        }
    }
} 
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
