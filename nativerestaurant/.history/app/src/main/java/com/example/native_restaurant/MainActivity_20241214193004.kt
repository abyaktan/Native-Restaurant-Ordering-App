package com.example.native_restaurant

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.native_restaurant.data.TokenManager
import com.example.native_restaurant.di.NetworkModule
import com.example.native_restaurant.navigation.Screen
import com.example.native_restaurant.ui.screens.*
import com.example.native_restaurant.ui.theme.NativerestaurantTheme
import com.example.native_restaurant.viewmodel.*

class MainActivity : ComponentActivity() {
    private lateinit var tokenManager: TokenManager
    private val api = NetworkModule.api

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tokenManager = TokenManager(applicationContext)

        enableEdgeToEdge()
        setContent {
            NativerestaurantTheme {
                val authViewModel = viewModel { AuthViewModel(api) }
                val productViewModel = viewModel { ProductViewModel(api) }
                val cartViewModel = viewModel { CartViewModel(api) }

                RestaurantApp(
                    authViewModel = authViewModel,
                    productViewModel = productViewModel,
                    cartViewModel = cartViewModel,
                    tokenManager = tokenManager
                )
            }
        }
    }
}

@Composable
fun RestaurantApp(
    authViewModel: AuthViewModel,
    productViewModel: ProductViewModel,
    cartViewModel: CartViewModel,
    tokenManager: TokenManager
) {
    val navController = rememberNavController()
    val token by tokenManager.getToken.collectAsState(initial = null)

    Scaffold(
        modifier = Modifier.fillMaxSize()
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = if (token == null) Screen.Login.route else Screen.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Login.route) {
                LoginScreen(
                    navController = navController,
                    authViewModel = authViewModel,
                    tokenManager = tokenManager
                )
            }
            composable(Screen.Register.route) {
                RegisterScreen(
                    navController = navController,
                    authViewModel = authViewModel
                )
            }
            composable(Screen.Home.route) {
                HomeScreen(
                    navController = navController,
                    viewModel = productViewModel
                )
            }
            composable(Screen.Cart.route) {
                token?.let { safeToken ->
                    CartScreen(
                        navController = navController,
                        cartViewModel = cartViewModel,
                        token = safeToken
                    )
                }
            }
            composable(
                route = Screen.ProductDetail.route,
                arguments = listOf(
                    navArgument("productId") { type = NavType.IntType }
                )
            ) { backStackEntry ->
                val productId = backStackEntry.arguments?.getInt("productId")
                productId?.let { id ->
                    token?.let { safeToken ->
                        val product = (productViewModel.productsState.value as? ProductState.Success)
                            ?.products
                            ?.find { it.id == id }

                        product?.let {
                            ProductDetailScreen(
                                navController = navController,
                                product = it,
                                cartViewModel = cartViewModel,
                                token = safeToken
                            )
                        }
                    }
                }
            }
        }
    }
}