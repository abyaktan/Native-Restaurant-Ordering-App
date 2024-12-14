package com.example.native_restaurant.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.native_restaurant.model.Cart
import com.example.native_restaurant.network.RestaurantApi
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
            try {
                val response = api.getCart("Bearer $token")
                if (response.isSuccessful) {
                    response.body()?.let { cartResponse ->
                        _cartState.value = CartState.Success(Cart(
                            items = cartResponse.items,
                            totalPrice = cartResponse.totalPrice
                        ))
                    }
                } else {
                    _cartState.value = CartState.Error("Failed to load cart")
                }
            } catch (e: Exception) {
                _cartState.value = CartState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun updateCartItem(token: String, productId: String, quantity: Int) {
        viewModelScope.launch {
            try {
                val response = api.updateCart(
                    token = "Bearer $token",
                    request = UpdateCartRequest(productId, quantity)
                )
                if (response.isSuccessful) {
                    loadCart(token)
                }
            } catch (e: Exception) {
                _cartState.value = CartState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun addToCart(token: String, productId: String, quantity: Int) {
        viewModelScope.launch {
            try {
                val response = api.addToCart(
                    token = "Bearer $token",
                    request = AddToCartRequest(productId, quantity)
                )
                if (response.isSuccessful) {
                    loadCart(token)
                }
            } catch (e: Exception) {
                _cartState.value = CartState.Error(e.message ?: "Unknown error")
            }
        }
    }
}