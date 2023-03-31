package com.example.cpr2u_android.di

import com.example.cpr2u_android.BuildConfig
import com.example.cpr2u_android.data.api.AuthService
import com.example.cpr2u_android.data.api.CallService
import com.example.cpr2u_android.data.api.EducationService
import com.example.cpr2u_android.data.sharedpref.CPR2USharedPreference
import com.google.gson.GsonBuilder
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import org.koin.dsl.module
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

val netWorkModule = module {
    single {
        OkHttpClient.Builder()
            .addInterceptor(
                Interceptor { chain ->
                    chain.proceed(
                        chain.request().newBuilder()
                            .addHeader(
                                "Authorization",
                                CPR2USharedPreference.getAccessToken(),
                            )
                            .build(),
                    )
                },
            )
            .build()
    }

    single<Retrofit> {
        Retrofit.Builder()
            .client(get())
            .addConverterFactory(GsonConverterFactory.create(GsonBuilder().setLenient().create()))
            .baseUrl(BuildConfig.BASE_URL)
            .build()
    }
    single<AuthService> {
        get<Retrofit>().create(AuthService::class.java)
    }
    single<EducationService> { get<Retrofit>().create(EducationService::class.java) }
    single<CallService> { get<Retrofit>().create(CallService::class.java)}
}
