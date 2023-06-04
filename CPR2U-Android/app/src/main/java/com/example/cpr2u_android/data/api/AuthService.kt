package com.example.cpr2u_android.data.api

import com.example.cpr2u_android.data.model.request.auth.RequestLogin
import com.example.cpr2u_android.data.model.request.auth.RequestSignUp
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.auth.ResponseAutoLogin
import com.example.cpr2u_android.data.model.response.auth.ResponseLogin
import com.example.cpr2u_android.data.model.response.auth.ResponsePhoneVerification
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

interface AuthService {

    @POST("auth/auto-login")
    suspend fun postAutoLogin(
        @Body refreshToken: String,
    ): ResponseAutoLogin

    @POST("auth/verification")
    suspend fun postVerification(
        @Body phone_number: String,
    ): ResponsePhoneVerification

    @POST("auth/login")
    suspend fun postLogin(
        @Body body: RequestLogin,
    ): ResponseLogin

    @GET("auth/nickname")
    suspend fun getNickname(
        @Query("nickname") nickName: String,
    ): GeneralResponse

    @POST("auth/signup")
    suspend fun postSignUp(
        @Body body: RequestSignUp,
    ): ResponseAutoLogin

    @POST("auth/logout")
    suspend fun postLogout(): GeneralResponse
}
