package com.example.cpr2u_android.data.repository.auth

import com.example.cpr2u_android.data.datasource.auth.AuthDataSource
import com.example.cpr2u_android.data.model.request.auth.RequestLogin
import com.example.cpr2u_android.data.model.request.auth.RequestSignUp
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.auth.ResponseAutoLogin
import com.example.cpr2u_android.data.model.response.auth.ResponseLogin
import com.example.cpr2u_android.data.model.response.auth.ResponsePhoneVerification
import com.example.cpr2u_android.domain.repository.auth.AuthRepository
import timber.log.Timber

class AuthRepositoryImpl(private val authDataSource: AuthDataSource) : AuthRepository {
    override suspend fun postAuthLogin(refreshToken: String): ResponseAutoLogin? {
        return authDataSource.postAutoLogin(refreshToken)
    }

    override suspend fun postVerification(phoneNumber: String): ResponsePhoneVerification {
        Timber.d("구현체 phoneNumber -> $phoneNumber")
        return authDataSource.postVerification(phoneNumber)
    }

    override suspend fun postLogin(loginData: RequestLogin): ResponseLogin {
        return authDataSource.postLogin(loginData)
    }

    override suspend fun getNickname(nickname: String): GeneralResponse {
        return authDataSource.getNickName(nickname)
    }

    override suspend fun postSignUp(signUpData: RequestSignUp): ResponseAutoLogin {
        return authDataSource.postSignUp(signUpData)
    }
}
