package com.example.native_restaurant.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.native_restaurant.model.Product
import com.example.native_restaurant.network.RestaurantApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class ProductState {
    object Loading : ProductState()
    data class Success(val products: List<Product>) : ProductState()
    data class Error(val message: String) : ProductState()
}

class ProductViewModel(
    private val api: RestaurantApi
) : ViewModel() {
    
    private val _productsState = MutableStateFlow<ProductState>(ProductState.Loading)
    val productsState: StateFlow<ProductState> = _productsState

    init {
        loadProducts()
    }

    private fun loadProducts() {
        viewModelScope.launch {
            try {
                val response = api.getProducts()
                if (response.isSuccessful) {
                    response.body()?.let { products ->
                        _productsState.value = ProductState.Success(products)
                    }
                } else {
                    _productsState.value = ProductState.Error("Failed to load products")
                }
            } catch (e: Exception) {
                _productsState.value = ProductState.Error(e.message ?: "Unknown error")
            }
        }
    }
}