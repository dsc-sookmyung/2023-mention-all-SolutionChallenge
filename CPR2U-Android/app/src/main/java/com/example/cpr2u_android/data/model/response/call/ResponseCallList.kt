package com.example.cpr2u_android.data.model.response.call

import com.google.gson.annotations.SerializedName

data class ResponseCallList(
    @SerializedName("data")
    val data: Data,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
) {
    data class Data(
        @SerializedName("angel_status")
        val angelStatus: String,
        @SerializedName("call_list")
        val callList: List<Call>,
        @SerializedName("is_patient")
        val isPatient: Boolean,
    ) {
        data class Call(
            @SerializedName("called_at")
            val calledAt: String,
            @SerializedName("cpr_call_id")
            val cprCallId: Int,
            @SerializedName("full_address")
            val fullAddress: String,
            @SerializedName("latitude")
            val latitude: Double,
            @SerializedName("longitude")
            val longitude: Double,
        )
    }
}
