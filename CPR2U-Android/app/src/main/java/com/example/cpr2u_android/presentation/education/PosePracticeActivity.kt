package com.example.cpr2u_android.presentation.education

import android.os.Bundle
import androidx.navigation.NavController
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.ActivityPosePracticeBinding
import com.example.cpr2u_android.presentation.base.BaseActivity

class PosePracticeActivity :
    BaseActivity<ActivityPosePracticeBinding>(R.layout.activity_pose_practice) {
    private lateinit var appBarConfiguration: AppBarConfiguration
    private lateinit var navController: NavController
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val navHostFragment =
            supportFragmentManager.findFragmentById(R.id.fcv_pose) as NavHostFragment
        navController = navHostFragment.navController
//        supportFragmentManager.beginTransaction().replace(R.id.fcv_pose, PosePractice1Fragment()).commit()
    }

//    override fun onSupportNavigateUp(): Boolean {
//        val navController = findNavController(R.id.nav_pose_practice)
//        return navController.navigateUp(appBarConfiguration) ||
//            super.onSupportNavigateUp()
//    }
}
