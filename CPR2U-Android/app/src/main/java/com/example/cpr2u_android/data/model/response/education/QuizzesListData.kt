package com.example.cpr2u_android.data.model.response.education

import com.google.gson.annotations.SerializedName

data class QuizzesListData(
    @SerializedName("index")
    val index: Int,
    @SerializedName("question")
    val question: String,
    @SerializedName("type")
    val type: Int,
    @SerializedName("answer")
    val answer: Int,
    @SerializedName("reason")
    val reason: String,
    @SerializedName("answer_list")
    val answerList: List<Answer>,
) {
    data class Answer(
        @SerializedName("content")
        val content: String,
        @SerializedName("id")
        val id: Int,
    )
}
