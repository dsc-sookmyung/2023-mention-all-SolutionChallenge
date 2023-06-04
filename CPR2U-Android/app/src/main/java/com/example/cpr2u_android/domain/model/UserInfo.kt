package com.example.cpr2u_android.domain.model

import com.google.gson.annotations.SerializedName

data class UserInfo(
    @SerializedName("angel_status")
    var angelStatus: Int,
    @SerializedName("days_left_until_expiration")
    var daysLeftUntilExpiration: Int,
    @SerializedName("is_lecture_completed")
    var isLectureCompleted: Int,
    @SerializedName("is_posture_completed")
    var isPostureCompleted: Int,
    @SerializedName("is_quiz_completed")
    var isQuizCompleted: Int,
    @SerializedName("nickname")
    var nickname: String,
    @SerializedName("progress_percent")
    var progressPercent: Double,
)
