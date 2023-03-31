package com.example.cpr2u_android.data.model.response.education

import com.google.gson.annotations.SerializedName

data class ResponseQuizzesList(
    @SerializedName("data")
    val data: List<QuizzesListData>,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
)
