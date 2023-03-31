package com.example.cpr2u_android.data.model.request.auth

import com.google.gson.annotations.SerializedName

data class RequestLogin(
    @SerializedName("device_token")
    val deviceToken: String,
    @SerializedName("phone_number")
    val phoneNumber: String,
)
