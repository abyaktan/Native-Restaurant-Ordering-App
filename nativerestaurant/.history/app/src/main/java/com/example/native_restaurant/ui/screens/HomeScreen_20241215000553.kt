package com.example.native_restaurant.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.native_restaurant.data.TokenManager
import com.example.native_restaurant.navigation.Screen
import com.example.native_restaurant.ui.components.LoadingIndicator
import com.example.native_restaurant.ui.components.ProductCard
import com.example.native_restaurant.viewmodel.ProductState
import com.example.native_restaurant.viewmodel.ProductViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    navController: NavController,
    viewModel: ProductViewModel,
    tokenManager: TokenManager
) {
    val productState by viewModel.productsState.collectAsState()
    val scope = rememberCoroutineScope()

    // Add this LaunchedEffect to trigger product loading when the screen is shown
    LaunchedEffect(Unit) {
        viewModel.loadProducts()
    }
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Restaurant Menu") },
                actions = {
                    IconButton(onClick = { navController.navigate(Screen.Cart.route) }) {
                        Icon(
                            imageVector = Icons.Default.ShoppingCart,
                            contentDescription = "Cart"
                        )
                    }
                    IconButton(
                        onClick = {
                            scope.launch {
                                tokenManager.deleteToken()
                                navController.navigate(Screen.Login.route) {
                                    popUpTo(navController.graph.id) { inclusive = true }
                                }
                            }
                        }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.ExitToApp, "Logout")
                    }
                }
            )
        }
    ) { paddingValues ->
        when (productState) {
            is ProductState.Loading -> LoadingIndicator()
            is ProductState.Error -> {
                Text(
                    text = (productState as ProductState.Error).message,
                    modifier = Modifier.padding(16.dp)
                )
            }
            is ProductState.Success -> {
                val products = (productState as ProductState.Success).products
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    contentPadding = paddingValues,
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(products) { product ->
                        ProductCard(
                            product = product,
                            onClick = {
                                navController.navigate(
                                    Screen.ProductDetail.createRoute(product.id)
                                )
                            }
                        )
                    }
                }
            }
        }
    }
}