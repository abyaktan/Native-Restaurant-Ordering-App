package com.example.native_restaurant

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.native_restaurant.navigation.Screen
import com.example.native_restaurant.ui.theme.NativerestaurantTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            NativerestaurantTheme {
                RestaurantApp()
            }
        }
    }
}

@Composable
fun RestaurantApp() {
    val navController = rememberNavController()
    
    Scaffold(
        modifier = Modifier.fillMaxSize()
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Login.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Login.route) {
                // LoginScreen(navController)
            }
            composable(Screen.Register.route) {
                // RegisterScreen(navController)
            }
            composable(Screen.Home.route) {
                // HomeScreen(navController)
            }
            composable(Screen.Cart.route) {
                // CartScreen(navController)
            }
            composable(
                route = Screen.ProductDetail.route
            ) {
                // ProductDetailScreen(navController)
            }
        }
    }
}