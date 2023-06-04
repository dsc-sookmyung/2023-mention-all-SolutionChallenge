package com.example.cpr2u_android.data.datasource.auth

import com.example.cpr2u_android.data.model.request.auth.RequestLogin
import com.example.cpr2u_android.data.model.request.auth.RequestSignUp
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.auth.ResponseAutoLogin
import com.example.cpr2u_android.data.model.response.auth.ResponseLogin
import com.example.cpr2u_android.data.model.response.auth.ResponsePhoneVerification

interface AuthDataSource {
    suspend fun postAutoLogin(refreshToken: String): ResponseAutoLogin
    suspend fun postVerification(phoneNumber: String): ResponsePhoneVerification
    suspend fun postLogin(loginData: RequestLogin): ResponseLogin
    suspend fun getNickName(nickname: String): GeneralResponse
    suspend fun postSignUp(signUpData: RequestSignUp): ResponseAutoLogin

    suspend fun postLogout(): GeneralResponse
}
