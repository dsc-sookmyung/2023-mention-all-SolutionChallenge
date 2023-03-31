package com.example.cpr2u_android.data.model.response.auth

import com.google.gson.annotations.SerializedName

data class ResponseLogin(
    @SerializedName("data")
    val data: LoginData,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
) {
    data class LoginData(
        @SerializedName("access_token")
        val accessToken: String,
        @SerializedName("refresh_token")
        val refreshToken: String,
    )
}
