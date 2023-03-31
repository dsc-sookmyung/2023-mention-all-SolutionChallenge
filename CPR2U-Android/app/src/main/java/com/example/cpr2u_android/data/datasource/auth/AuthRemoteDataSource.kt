package com.example.cpr2u_android.data.datasource.auth

import com.example.cpr2u_android.data.api.AuthService
import com.example.cpr2u_android.data.model.request.auth.RequestLogin
import com.example.cpr2u_android.data.model.request.auth.RequestSignUp
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.auth.ResponseAutoLogin
import com.example.cpr2u_android.data.model.response.auth.ResponseLogin
import com.example.cpr2u_android.data.model.response.auth.ResponsePhoneVerification

class AuthRemoteDataSource(private val authService: AuthService) : AuthDataSource {
    override suspend fun postAutoLogin(refreshToken: String): ResponseAutoLogin {
        return authService.postAutoLogin(refreshToken)
    }

    override suspend fun postVerification(phoneNumber: String): ResponsePhoneVerification {
        return authService.postVerification(phoneNumber)
    }

    override suspend fun postLogin(loginData: RequestLogin): ResponseLogin {
        return authService.postLogin(loginData)
    }

    override suspend fun getNickName(nickname: String): GeneralResponse {
        return authService.getNickname(nickname)
    }

    override suspend fun postSignUp(signUpData: RequestSignUp): ResponseAutoLogin {
        return authService.postSignUp(signUpData)
    }
}
