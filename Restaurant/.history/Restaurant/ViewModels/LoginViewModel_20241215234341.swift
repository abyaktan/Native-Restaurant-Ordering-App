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
} 
