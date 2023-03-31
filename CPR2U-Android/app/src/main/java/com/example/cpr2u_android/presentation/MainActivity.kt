package com.example.cpr2u_android.presentation

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.ActivityMainBinding
import com.example.cpr2u_android.presentation.base.BaseActivity
import com.example.cpr2u_android.presentation.call.CallFragment
import com.example.cpr2u_android.presentation.education.EducationFragment
import com.example.cpr2u_android.presentation.profile.ProfileFragment

class MainActivity : BaseActivity<ActivityMainBinding>(R.layout.activity_main) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding.bottomNavigation.selectedItemId = R.id.menu_call
        binding.bottomNavigation.setOnItemSelectedListener {
            when (it.itemId) {
                R.id.menu_education -> {
                    Log.d("education clicked", "")
                    changeFragment(EducationFragment())
                    return@setOnItemSelectedListener true
                }
                R.id.menu_call -> {
                    Log.d("call clicked", "")
                    changeFragment(CallFragment())
                    return@setOnItemSelectedListener true
                }
                R.id.menu_profile -> {
                    Log.d("profile clicked", "")
                    changeFragment(ProfileFragment())
                    return@setOnItemSelectedListener true
                }
                else -> return@setOnItemSelectedListener false
            }
        }
    }

    private fun changeFragment(fragment: Fragment) {
        supportFragmentManager.beginTransaction().replace(R.id.fcv_main, fragment).commit()
    }
}
