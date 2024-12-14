package com.example.native_restaurant.network

import retrofit2.Response
import retrofit2.http.*

interface RestaurantApi {
    @POST("login")
    suspend fun login(
        @Body credentials: LoginRequest
    ): Response<LoginResponse>

    @POST("register")
    suspend fun register(
        @Body request: RegisterRequest
    ): Response<RegisterResponse>

    @GET("products")
    suspend fun getProducts(): Response<List<Product>>

    @GET("cart")
    suspend fun getCart(
        @Header("Authorization") token: String
    ): Response<CartResponse>

    @POST("cart/add")
    suspend fun addToCart(
        @Header("Authorization") token: String,
        @Body request: AddToCartRequest
    ): Response<CartResponse>

    @PUT("cart/update")
    suspend fun updateCart(
        @Header("Authorization") token: String,
        @Body request: UpdateCartRequest
    ): Response<CartResponse>
}

// Data classes for requests and responses
data class LoginRequest(
    val username: String,
    val password: String
)

data class LoginResponse(
    val token: String,
    val message: String
)

data class RegisterRequest(
    val username: String,
    val password: String
)

data class RegisterResponse(
    val message: String
)

data class Product(
    val id: String,
    val name: String,
    val price: Double,
    val imageUrl: String,
    val description: String
)

data class CartResponse(
    val items: List<CartItem>,
    val totalPrice: Double
)

data class CartItem(
    val product: Product,
    val quantity: Int
)

data class AddToCartRequest(
    val productId: String,
    val quantity: Int
)

data class UpdateCartRequest(
    val productId: String,
    val quantity: Int
) 