import Foundation
import AuthenticationServices

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private let authManager = AuthenticationManager.shared
    
    func login() async {
        isLoading = true
        error = nil
        
        do {
            try await authManager.login(username: username, password: password)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func handleICloudSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Here you would typically send the user identifier to your backend
                // to create or fetch the user account
                let userIdentifier = appleIDCredential.user
                Task {
                    await loginWithICloud(userIdentifier: userIdentifier)
                }
            }
        case .failure(let error):
            self.error = error.localizedDescription
        }
    }
    
    private func loginWithICloud(userIdentifier: String) async {
        isLoading = true
        error = nil
        
        do {
            // Here you would typically make an API call to your backend
            // to validate the iCloud credentials and get a token
            // For now, we'll use a dummy implementation
            try await authManager.login(username: userIdentifier, password: "icloud_login")
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
} 
