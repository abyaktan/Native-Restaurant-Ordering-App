package com.example.native_restaurant.viewmodel

import android.util.Log
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

    fun loadProducts() {
        viewModelScope.launch {
            _productsState.value = ProductState.Loading
            try {
                val response = api.getProducts()
                if (response.isSuccessful) {
                    response.body()?.let { networkProducts ->
                        Log.d("ProductViewModel", "Raw response: $networkProducts")

                        val products = networkProducts.map { networkProduct ->
                            Product(
                                id = networkProduct.product_id,
                                name = networkProduct.name,
                                price = networkProduct.price,
                                description = networkProduct.description ?: "",
                                imageUrl = networkProduct.image_url ?: ""
                            )
                        }
                        _productsState.value = ProductState.Success(products)
                    } ?: run {
                        _productsState.value = ProductState.Error("No products found")
                    }
                } else {
                    val errorBody = response.errorBody()?.string()
                    Log.e("ProductViewModel", "Error response: $errorBody")
                    _productsState.value = ProductState.Error("Failed to load products: ${response.code()}")
                }
            } catch (e: Exception) {
                Log.e("ProductViewModel", "Error loading products", e)
                _productsState.value = ProductState.Error("Error loading products: ${e.message}")
            }
        }
    }
}