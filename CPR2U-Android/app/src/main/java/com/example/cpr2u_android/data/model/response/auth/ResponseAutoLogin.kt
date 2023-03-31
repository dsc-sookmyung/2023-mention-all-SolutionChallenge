package com.example.cpr2u_android.data.model.response.auth

import com.google.gson.annotations.SerializedName

data class ResponseAutoLogin(
    @SerializedName("data")
    val data: AutoLoginData,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
)

data class AutoLoginData(
    @SerializedName("access_token")
    val accessToken: String,
    @SerializedName("refresh_token")
    val refreshToken: String,
)
