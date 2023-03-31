package com.example.cpr2u_android.presentation.splash

import android.content.ContentValues
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.cpr2u_android.data.sharedpref.CPR2USharedPreference
import com.example.cpr2u_android.domain.repository.auth.AuthRepository
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.launch
import timber.log.Timber

class SplashViewModel(private val authRepository: AuthRepository) : ViewModel() {

    private val _deviceToken = MutableLiveData<String>()
    var deviceToken: LiveData<String> = _deviceToken

    private val _refreshToken = MutableLiveData<String>()
    var refreshToken: LiveData<String> = _refreshToken

    private val _autoLogin = MutableLiveData<Boolean>()
    var autoLogin: LiveData<Boolean> = _autoLogin

    fun postAutoLogin(refreshToken: String) = viewModelScope.launch {
        kotlin.runCatching {
            authRepository.postAuthLogin(refreshToken)
        }
            .onSuccess {
                Timber.d("자동로그인 성공 $it")
                _autoLogin.value = true
                _refreshToken.value = it?.data?.refreshToken
                CPR2USharedPreference.setRefreshToken(_refreshToken.value.toString())
            }
            .onFailure {
                _autoLogin.value = false
                Timber.d("자동로그인 실패 $it")
            }
    }

    fun getDeviceToken() {
        viewModelScope.launch {
            kotlin.runCatching {
                FirebaseMessaging.getInstance().token.addOnCompleteListener(
                    OnCompleteListener { task ->
                        if (!task.isSuccessful) {
                            Timber.tag(ContentValues.TAG)
                                .w(task.exception, "Fetching FCM registration token failed")
                            return@OnCompleteListener
                        }
                        _deviceToken.value = task.result
                    },
                )
            }
        }
    }
}
