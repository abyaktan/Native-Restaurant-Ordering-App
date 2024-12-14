package com.example.native_restaurant.model

data class User(
    val username: String,
    val token: String
)

data class Product(
    val id: Int,
    val name: String,
    val price: Double,
    val description: String,
    val imageUrl: String
)

data class CartItem(
    val product: Product,
    val quantity: Int
)

data class Cart(
    val items: List<CartItem>,
    val totalPrice: Double
)