//
//  RegistrationViewModel.swift
//  Restaurant
//
//  Created by Tri Haryanto on 06/12/24.
//

import Foundation

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var verifyPassword = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var registrationSuccess = false
    
    private let networkManager = NetworkManager.shared
    
    var isPasswordValid: Bool {
        password.count >= 8
    }
    
    var passwordsMatch: Bool {
        password == verifyPassword
    }
    
    var isFormValid: Bool {
        !username.isEmpty && isPasswordValid && passwordsMatch
    }
    
    func register() async {
        guard isFormValid else {
            if !isPasswordValid {
                error = "Password must be at least 8 characters long"
            } else if !passwordsMatch {
                error = "Passwords do not match"
            } else {
                error = "Please fill in all fields"
            }
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            try await networkManager.register(username: username, password: password)
            registrationSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}
