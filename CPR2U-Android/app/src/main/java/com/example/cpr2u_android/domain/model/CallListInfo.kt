package com.example.cpr2u_android.domain.model

import com.google.gson.annotations.SerializedName

data class CallListInfo(
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
