package com.example.cpr2u_android.data.model.response.call


import com.google.gson.annotations.SerializedName

data class ResponseNumbersOfAngel(
    @SerializedName("data")
    val `data`: Data,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int
) {
    data class Data(
        @SerializedName("number_of_angels")
        val numberOfAngels: Int
    )
}