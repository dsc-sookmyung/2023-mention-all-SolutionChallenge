package com.example.cpr2u_android.data.model.response.call

import com.google.gson.annotations.SerializedName

data class ResponseDispatch(
    @SerializedName("data")
    val data: Data,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
) {
    data class Data(
        @SerializedName("called_at")
        val calledAt: String,
        @SerializedName("dispatch_id")
        val dispatchId: Int,
        @SerializedName("full_address")
        val fullAddress: String,
        @SerializedName("latitude")
        val latitude: Double,
        @SerializedName("longitude")
        val longitude: Double,
    )
}
