import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case registrationError(String)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://your-api-base-url"
    private var authToken: String?
    
    private init() {}
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    private func createRequest(_ endpoint: String, method: String = "GET", body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    func register(username: String, password: String) async throws {
        guard let request = createRequest("/register", method: "POST", body: try? JSONEncoder().encode([
            "username": username,
            "password": password
        ])) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
               let message = errorResponse["error"] {
                throw NetworkError.registrationError(message)
            }
            throw NetworkError.serverError("Registration failed: \(httpResponse.statusCode)")
        }
    }
    
    func login(username: String, password: String) async throws -> String {
        guard let request = createRequest("/login", method: "POST", body: try? JSONEncoder().encode([
            "username": username,
            "password": password
        ])) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
        
        struct LoginResponse: Codable {
            let success: Bool
            let token: String
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        guard loginResponse.success else {
            throw NetworkError.serverError("Login failed")
        }
        
        return loginResponse.token
    }
    
    func fetchProducts() async throws -> [Product] {
        guard let request = createRequest("/products") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode([Product].self, from: data)
    }
    
    func fetchCart() async throws -> [CartItem] {
        guard let request = createRequest("/cart") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode([CartItem].self, from: data)
    }
    
    func addToCart(productId: Int, quantity: Int) async throws {
        guard let request = createRequest("/cart/add", method: "POST", body: try? JSONEncoder().encode([
            "productId": productId,
            "quantity": quantity
        ])) else {
            throw NetworkError.invalidURL
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
} 
