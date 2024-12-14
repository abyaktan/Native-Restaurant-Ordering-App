package com.example.native_restaurant.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.native_restaurant.network.LoginRequest
import com.example.native_restaurant.network.RegisterRequest
import com.example.native_restaurant.network.RestaurantApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch


class AuthViewModel(
    private val api: RestaurantApi
) : ViewModel() {

    private val _loginState = MutableStateFlow<AuthState>(AuthState.Initial)
    val loginState: StateFlow<AuthState> = _loginState

    private val _registerState = MutableStateFlow<AuthState>(AuthState.Initial)
    val registerState: StateFlow<AuthState> = _registerState

    fun login(username: String, password: String) {
        viewModelScope.launch {
            _loginState.value = AuthState.Loading
            try {
                val response = api.login(LoginRequest(username, password))
                if (response.isSuccessful) {
                    response.body()?.let {
                        _loginState.value = AuthState.Success(it.token)
                    }
                } else {
                    val errorBody = response.errorBody()?.string()
                    _loginState.value = AuthState.Error("Login failed: $errorBody")
                }
            } catch (e: Exception) {
                _loginState.value = AuthState.Error("Error: ${e.message}")
                Log.e("AuthViewModel", "Login error", e) // Add this line for debugging
            }
        }
    }

    fun register(username: String, password: String) {
        viewModelScope.launch {
            _registerState.value = AuthState.Loading
            try {
                val response = api.register(RegisterRequest(username, password))
                if (response.isSuccessful) {
                    _registerState.value = AuthState.Success("")
                } else {
                    _registerState.value = AuthState.Error("Registration failed")
                }
            } catch (e: Exception) {
                _registerState.value = AuthState.Error(e.message ?: "Unknown error")
            }
        }
    }
}

sealed class AuthState {
    object Initial : AuthState()
    object Loading : AuthState()
    data class Success(val token: String) : AuthState()
    data class Error(val message: String) : AuthState()
}

