package com.example.cpr2u_android.data.model.request


import com.google.gson.annotations.SerializedName

data class RequestDispatchReport(
    @SerializedName("content")
    val content: String,
    @SerializedName("dispatch_id")
    val dispatchId: Int
)