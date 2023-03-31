package com.example.cpr2u_android.util

sealed interface UiState<out T> {
    object Loading : UiState<Nothing>

    data class Success<T>(
        val data: T,
    ) : UiState<T>

    data class Failure(
        val msg: String?,
    ) : UiState<Nothing>
}