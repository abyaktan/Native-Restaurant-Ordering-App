//
//  RestaurantApp.swift
//  Restaurant
//
//  Created by Tri Haryanto on 02/12/24.
//

import SwiftUI

@main
struct RestaurantApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Group {
                    if authManager.isAuthenticated {
                        HomeView()
                    } else {
                        LoginView()
                    }
                }
            }
            .environmentObject(authManager)
        }
    }
}
