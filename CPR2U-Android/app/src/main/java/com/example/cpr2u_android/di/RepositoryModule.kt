package com.example.cpr2u_android.di

import com.example.cpr2u_android.data.repository.auth.AuthRepositoryImpl
import com.example.cpr2u_android.data.repository.call.CallRepositoryImpl
import com.example.cpr2u_android.data.repository.education.EducationRepositoryImpl
import com.example.cpr2u_android.domain.repository.auth.AuthRepository
import com.example.cpr2u_android.domain.repository.call.CallRepository
import com.example.cpr2u_android.domain.repository.education.EducationRepository
import org.koin.dsl.module

val repositoryModule = module {
    single<AuthRepository> { AuthRepositoryImpl(get()) }
    single<EducationRepository> { EducationRepositoryImpl(get()) }
    single<CallRepository> { CallRepositoryImpl(get()) }
}
