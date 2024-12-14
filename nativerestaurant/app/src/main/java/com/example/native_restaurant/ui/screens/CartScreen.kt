package com.example.native_restaurant.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.native_restaurant.ui.components.CartItemCard
import com.example.native_restaurant.viewmodel.CartState
import com.example.native_restaurant.viewmodel.CartViewModel
import androidx.compose.foundation.lazy.items

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CartScreen(
    navController: NavController,
    cartViewModel: CartViewModel,
    token: String
) {
    val cartState by cartViewModel.cartState.collectAsState()

    LaunchedEffect(Unit) {
        cartViewModel.loadCart(token)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Shopping Cart") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        when (cartState) {
            is CartState.Loading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
            is CartState.Error -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = (cartState as CartState.Error).message,
                        color = MaterialTheme.colorScheme.error
                    )
                }
            }
            is CartState.Success -> {
                val cart = (cartState as CartState.Success).cart
                if (cart.items.isEmpty()) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(paddingValues),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("Your cart is empty")
                    }
                } else {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(paddingValues)
                    ) {
                        LazyColumn(
                            modifier = Modifier.weight(1f)
                        ) {
                            items(cart.items) { cartItem ->
                                CartItemCard(
                                    cartItem = cartItem,
                                    onQuantityChange = { newQuantity ->
                                        cartViewModel.updateCartItem(
                                            token,
                                            cartItem.product.id,
                                            newQuantity
                                        )
                                    },
                                    onRemove = {
                                        cartViewModel.removeFromCart(
                                            token,
                                            cartItem.product.id
                                        )
                                    }
                                )
                            }
                        }

                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp)
                        ) {
                            Column(
                                modifier = Modifier.padding(16.dp)
                            ) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = "Total:",
                                        style = MaterialTheme.typography.titleLarge
                                    )
                                    Text(
                                        text = "Rp${String.format("%,.0f", cart.totalPrice)}",
                                        style = MaterialTheme.typography.titleLarge
                                    )
                                }

                                Spacer(modifier = Modifier.height(16.dp))

                                Button(
                                    onClick = {
                                        // TODO: Implement checkout
                                    },
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Text("Checkout")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}