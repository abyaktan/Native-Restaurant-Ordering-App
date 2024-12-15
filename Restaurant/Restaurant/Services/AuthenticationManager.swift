import Foundation
import LocalAuthentication

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    @Published var isAuthenticated = false
    private let tokenKey = "authToken"
    
    private init() {
        // Check for existing token on launch
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            NetworkManager.shared.setAuthToken(token)
            isAuthenticated = true
        }
    }
    
    func login(username: String, password: String) async throws {
        let token = try await NetworkManager.shared.login(username: username, password: password)
        await MainActor.run {
            self.saveToken(token)
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        NetworkManager.shared.clearAuthToken()
        isAuthenticated = false
    }
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        NetworkManager.shared.setAuthToken(token)
        isAuthenticated = true
    }
} 
