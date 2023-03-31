package com.example.cpr2u_android.data.api

import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.call.ResponseAddress
import com.example.cpr2u_android.data.model.response.education.ResponseQuizzesList
import com.example.cpr2u_android.data.model.response.education.ResponseUserInfo
import retrofit2.http.*

interface EducationService {
    @POST("education/lectures/progress/{lectureId}")
    suspend fun postLectureProgress(
        @Path("lectureId") lectureId: Int,
    ): GeneralResponse

    @GET("education/quizzes")
    suspend fun getQuizzes(): ResponseQuizzesList

    @POST("quizzes/progress")
    suspend fun postQuizProgress(
        @Body score: Int,
    ): GeneralResponse

    @POST("education/exercises/progress")
    suspend fun postExercisesProgress(
        @Body score: Int,
    ): GeneralResponse

    @GET("education")
    suspend fun getUserInfo(): ResponseUserInfo

    @GET("/users/address")
    suspend fun getAddress(): ResponseAddress
}
