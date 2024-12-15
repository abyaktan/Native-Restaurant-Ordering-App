import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var showBiometricLogin = false
    
    private let authManager = AuthenticationManager.shared
    
    init() {
        checkBiometricAvailability()
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        showBiometricLogin = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
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
    
    func authenticateWithBiometrics() async {
        isLoading = true
        error = nil
        
        do {
            if try await authManager.authenticateWithBiometrics() {
                // Here you would typically validate with your backend
                // For demo purposes, we'll just set a dummy token
                try await authManager.login(username: "biometric_user", password: "biometric_pass")
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
} 