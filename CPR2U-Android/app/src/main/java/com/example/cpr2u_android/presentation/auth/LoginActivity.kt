package com.example.cpr2u_android.presentation.auth

import android.os.Bundle
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.ActivityLoginBinding
import com.example.cpr2u_android.presentation.base.BaseActivity

class LoginActivity : BaseActivity<ActivityLoginBinding>(R.layout.activity_login) {

    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initNavigation()
    }

    private fun initNavigation() {
        val navHostFragment =
            supportFragmentManager.findFragmentById(R.id.fcv_login) as NavHostFragment
        navController = navHostFragment.navController
    }
}
