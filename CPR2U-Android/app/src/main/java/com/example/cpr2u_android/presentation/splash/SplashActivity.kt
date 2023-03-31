package com.example.cpr2u_android.presentation.splash

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import com.example.cpr2u_android.R
import com.example.cpr2u_android.data.sharedpref.CPR2USharedPreference
import com.example.cpr2u_android.presentation.MainActivity
import com.example.cpr2u_android.presentation.auth.LoginActivity
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber

class SplashActivity : AppCompatActivity() {
    private val splashViewModel: SplashViewModel by viewModel()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initSplash()

        Timber.d("access token -> ${CPR2USharedPreference.getAccessToken()}")
        Timber.d("device token -> ${CPR2USharedPreference.getDeviceToken()}")
        setContentView(R.layout.activity_splash)
    }

    private fun initSplash() {
        Handler(
            Looper.getMainLooper(),
        ).postDelayed({
            checkDeviceToken()
        }, SPLASH_VIEW_TIME)
    }

    private fun checkDeviceToken() {
        if (CPR2USharedPreference.getDeviceToken() == "") {
            splashViewModel.getDeviceToken()
            splashViewModel.deviceToken.observe(this) {
                Timber.d("device token $it")
                CPR2USharedPreference.setDeviceToken(it)
                navigateToNext()
            }
        } else {
            navigateToNext()
        }
    }

    private fun navigateToNext() {
        Timber.d("isLogin ${CPR2USharedPreference.getIsLogin()}")
        splashViewModel.postAutoLogin(CPR2USharedPreference.getRefreshToken())
        splashViewModel.autoLogin.observe(this) {
            if (it) {
                Timber.d("activity -> 자동로그인 성공")
                LoginActivity::class.java
                startActivity(Intent(this@SplashActivity, MainActivity::class.java))
                finish()
            } else {
                Timber.d("activity -> 자동로그인 실패")
                startActivity(Intent(this@SplashActivity, LoginActivity::class.java))
                finish()
            }
        }
    }

    companion object {
        const val SPLASH_VIEW_TIME = 1200L
    }
}
