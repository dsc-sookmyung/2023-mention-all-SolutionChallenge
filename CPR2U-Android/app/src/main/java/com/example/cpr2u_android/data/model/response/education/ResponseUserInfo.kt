package com.example.cpr2u_android.data.model.response.education

import com.google.gson.annotations.SerializedName

data class ResponseUserInfo(
    @SerializedName("data")
    val data: Data,
    @SerializedName("message")
    val message: String,
    @SerializedName("status")
    val status: Int,
) {
    data class Data(
        @SerializedName("angel_status")
        val angelStatus: Int,
        @SerializedName("days_left_until_expiration")
        val daysLeftUntilExpiration: Int,
        @SerializedName("is_lecture_completed")
        val isLectureCompleted: Int,
        @SerializedName("is_posture_completed")
        val isPostureCompleted: Int,
        @SerializedName("is_quiz_completed")
        val isQuizCompleted: Int,
        @SerializedName("last_lecture_title")
        val lastLectureTitle: String,
        @SerializedName("nickname")
        val nickname: String,
        @SerializedName("progress_percent")
        val progressPercent: Double,
    )
}
