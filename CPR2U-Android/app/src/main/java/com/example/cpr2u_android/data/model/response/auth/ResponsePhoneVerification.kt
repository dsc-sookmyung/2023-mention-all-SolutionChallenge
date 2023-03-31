package com.example.cpr2u_android.data.model.response.auth

import com.google.gson.annotations.SerializedName

data class ResponsePhoneVerification(
    @SerializedName("data")
    val data: ValidationCodeData,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
)

data class ValidationCodeData(
    @SerializedName("validation_code")
    val validationCode: String,
)
