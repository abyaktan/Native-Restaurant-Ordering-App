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
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        NetworkManager.shared.setAuthToken(token)
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw error ?? NSError(domain: "BiometricError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Biometric authentication not available"])
        }
        
        let reason = "Log in to your account"
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }
} 