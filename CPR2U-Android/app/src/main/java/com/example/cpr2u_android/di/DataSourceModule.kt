package com.example.cpr2u_android.di

import com.example.cpr2u_android.data.api.EducationService
import com.example.cpr2u_android.data.datasource.auth.AuthDataSource
import com.example.cpr2u_android.data.datasource.auth.AuthRemoteDataSource
import com.example.cpr2u_android.data.datasource.call.CallDataSource
import com.example.cpr2u_android.data.datasource.call.CallRemoteDataSource
import com.example.cpr2u_android.data.datasource.education.EducationDataSource
import com.example.cpr2u_android.data.datasource.education.EducationRemoteDataSource
import org.koin.dsl.module

val dataSourceModule = module {
    single<AuthDataSource> { AuthRemoteDataSource(get()) }
    single<EducationDataSource> { EducationRemoteDataSource(get()) }
    single<CallDataSource> { CallRemoteDataSource(get()) }
}
