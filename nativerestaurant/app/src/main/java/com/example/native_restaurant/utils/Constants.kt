package com.example.native_restaurant.utils

object Constants {
    const val BASE_URL = "http://10.0.2.2:3000/" // For Android Emulator accessing localhost

    // API Endpoints
    const val LOGIN_ENDPOINT = "login"
    const val REGISTER_ENDPOINT = "register"
    const val PRODUCTS_ENDPOINT = "products"
    const val CART_ENDPOINT = "cart"
    const val ADD_TO_CART_ENDPOINT = "cart/add"
    const val UPDATE_CART_ENDPOINT = "cart/update"

    // Shared Preferences
    const val PREFS_NAME = "restaurant_prefs"
    const val TOKEN_KEY = "jwt_token"
}