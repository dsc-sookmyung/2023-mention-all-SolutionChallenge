package com.example.cpr2u_android.data.model.response.call

import com.google.gson.annotations.SerializedName

data class ResponseCall(
    @SerializedName("data")
    val data: Data,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
) {
    data class Data(
        @SerializedName("call_id")
        val callId: Int,
    )
}
