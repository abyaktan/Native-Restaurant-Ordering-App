package com.example.native_restaurant.utils

sealed class ApiResponse<out T> {
        data class Success<out T>(val data: T) : ApiResponse<T>()
        data class Error(val message: String) : ApiResponse<Nothing>()
        object Loading : ApiResponse<Nothing>()
    }

suspend fun <T> safeApiCall(apiCall: suspend () -> T): ApiResponse<T> {
        return try {
                ApiResponse.Success(apiCall())
            } catch (e: Exception) {
                ApiResponse.Error(e.message ?: "An unknown error occurred")
            }
    }