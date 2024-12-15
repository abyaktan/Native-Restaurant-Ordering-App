import Foundation
import AuthenticationServices

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var loginSuccess = false
    
    private let authManager = AuthenticationManager.shared
    
    func login() async {
        isLoading = true
        error = nil
        
        do {
            try await authManager.login(username: username, password: password)
            loginSuccess = true
        } catch {
            print("Login error:", error)
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func handleICloudSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    await loginWithApple(credential: appleIDCredential)
                }
            }
        case .failure(let error):
            self.error = error.localizedDescription
        }
    }
    
    private func loginWithApple(credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true
        error = nil
        
        do {
            let token = try await NetworkManager.shared.loginWithApple(
                userId: credential.user,
                email: credential.email,
                fullName: credential.fullName
            )
            
            // Save the token and update authentication state
            await MainActor.run {
                authManager.saveToken(token)
                loginSuccess = true
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
} 
