package com.example.cpr2u_android.di

import com.example.cpr2u_android.presentation.auth.AuthViewModel
import com.example.cpr2u_android.presentation.call.CallViewModel
import com.example.cpr2u_android.presentation.education.EducationViewModel
import com.example.cpr2u_android.presentation.splash.SplashViewModel
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module

val viewModelModule = module {
    viewModel { SplashViewModel(get()) }
    viewModel { AuthViewModel(get()) }
    viewModel { EducationViewModel(get()) }
    viewModel { CallViewModel(get()) }
}
