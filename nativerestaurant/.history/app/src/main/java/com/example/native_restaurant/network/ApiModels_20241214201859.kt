package com.example.native_restaurant.network

// Request Models
data class LoginRequest(
        val username: String,
        val password: String
    )

data class RegisterRequest(
        val username: String,
        val password: String
    )

data class CartRequest(
        val productId: Int,
        val quantity: Int
    )

data class UpdateCartRequest(
        val productId: Int,
        val quantity: Int
    )

// Response Models
data class LoginResponse(
        val token: String,
        val message: String
    )

data class RegisterResponse(
        val message: String
    )

data class Product(
    val product_id: Int,
    val name: String,
    val price: Double,
    val description: String?,
    val image_url: String?
)

data class CartItemResponse(
    val product_id: Int,
    val name: String,
    val price: String,
    val quantity: Int,
    val image_url: String?
)
