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
    ): Response<List<CartItemResponse>>

    @POST("cart/add")
    suspend fun addToCart(
        @Header("Authorization") token: String,
        @Body request: CartRequest
    ): Response<Unit>

    @PUT("cart/update")
    suspend fun updateCart(
        @Header("Authorization") token: String,
        @Body request: UpdateCartRequest
    ): Response<Unit>

    @HTTP(method = "DELETE", path = "cart/remove", hasBody = true)
    suspend fun removeFromCart(
        @Header("Authorization") token: String,
        @Body request: RemoveCartRequest
    ): Response<Unit>
}