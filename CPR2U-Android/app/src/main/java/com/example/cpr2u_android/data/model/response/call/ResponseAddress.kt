package com.example.cpr2u_android.data.model.response.call

import com.google.gson.annotations.SerializedName

data class ResponseAddress(
    @SerializedName("data")
    val data: List<Data>,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
) {
    data class Data(
        @SerializedName("gugun_list")
        val gugunList: List<Gugun>,
        @SerializedName("sido")
        val sido: String,
    ) {
        data class Gugun(
            @SerializedName("gugun")
            val gugun: String,
            @SerializedName("id")
            val id: Int,
        )
    }
}
