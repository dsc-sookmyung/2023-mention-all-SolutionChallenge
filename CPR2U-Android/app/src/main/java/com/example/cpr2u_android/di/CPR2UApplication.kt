package com.example.cpr2u_android.di

import android.app.Application
import com.example.cpr2u_android.BuildConfig
import com.example.cpr2u_android.data.sharedpref.CPR2USharedPreference
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import timber.log.Timber

class CPR2UApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        startKoin {
            androidContext(this@CPR2UApplication)
            modules(
                netWorkModule,
                dataSourceModule,
                repositoryModule,
                viewModelModule,
            )
        }

        CPR2USharedPreference.init(applicationContext)

        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
    }
}
