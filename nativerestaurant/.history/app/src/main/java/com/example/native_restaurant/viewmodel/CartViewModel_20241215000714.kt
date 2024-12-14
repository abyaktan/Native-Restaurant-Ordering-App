package com.example.native_restaurant.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.native_restaurant.model.Cart
import com.example.native_restaurant.model.CartItem
import com.example.native_restaurant.model.Product
import com.example.native_restaurant.network.RestaurantApi
import com.example.native_restaurant.network.CartRequest
import com.example.native_restaurant.network.UpdateCartRequest
import com.example.native_restaurant.network.RemoveCartRequest
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class CartState {
    object Loading : CartState()
    data class Success(val cart: Cart) : CartState()
    data class Error(val message: String) : CartState()
}

class CartViewModel(
    private val api: RestaurantApi
) : ViewModel() {

    private val _cartState = MutableStateFlow<CartState>(CartState.Loading)
    val cartState: StateFlow<CartState> = _cartState

    fun loadCart(token: String) {
        viewModelScope.launch {
            _cartState.value = CartState.Loading
            try {
                val response = api.getCart("Bearer $token")
                if (response.isSuccessful) {
                    response.body()?.let { cartItems ->
                        val items = cartItems.map { item ->
                            CartItem(
                                product = Product(
                                    id = item.product_id,
                                    name = item.name,
                                    price = item.price.toDouble(),
                                    description = "",
                                    imageUrl = item.image_url ?: ""
                                ),
                                quantity = item.quantity
                            )
                        }
                        val totalPrice = items.sumOf { it.product.price * it.quantity }
                        _cartState.value = CartState.Success(Cart(items, totalPrice))
                    }
                } else {
                    _cartState.value = CartState.Error("Failed to load cart")
                }
            } catch (e: Exception) {
                _cartState.value = CartState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun updateCartItem(token: String, productId: Int, quantity: Int) {
        viewModelScope.launch {
            try {
                val response = api.updateCart(
                    token = "Bearer $token",
                    request = UpdateCartRequest(productId = productId, quantity = quantity)
                )
                if (response.isSuccessful) {
                    loadCart(token)
                } else {
                    val errorBody = response.errorBody()?.string()
                    _cartState.value = CartState.Error("Failed to update cart: $errorBody")
                }
            } catch (e: Exception) {
                _cartState.value = CartState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun addToCart(token: String, productId: Int, quantity: Int) {
        viewModelScope.launch {
            try {
                val response = api.addToCart(
                    token = "Bearer $token",
                    request = CartRequest(productId = productId, quantity = quantity)
                )
                if (response.isSuccessful) {
                    loadCart(token)
                } else {
                    _cartState.value = CartState.Error("Failed to add to cart")
                }
            } catch (e: Exception) {
                _cartState.value = CartState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun removeFromCart(token: String, productId: Int) {
        viewModelScope.launch {
            try {
                val response = api.removeFromCart(
                    token = "Bearer $token",
                    request = RemoveCartRequest(productId = productId)
                )
                if (response.isSuccessful) {
                    loadCart(token)
                } else {
                    val errorBody = response.errorBody()?.string()
                    _cartState.value = CartState.Error("Failed to remove item from cart: $errorBody")
                }
            } catch (e: Exception) {
                _cartState.value = CartState.Error("Error: ${e.message}")
            }
        }
    }
}