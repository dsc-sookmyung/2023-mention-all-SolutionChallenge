package com.example.cpr2u_android.presentation.education

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.example.cpr2u_android.R

class OnBoardingViewPagerAdapter(
    fragmentActivity: FragmentActivity?,
    private val context: Context,
) :
    FragmentStateAdapter(fragmentActivity!!) {

    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> OnBoardingFragment.newInstance(
                "Prepare tools",
                "If you do not have a CPR mannequin, \nplease prepare a plastic bottle, pillow, etc.",
                R.drawable.onboarding1,
            )
            1 -> OnBoardingFragment.newInstance(
                "Prepare tools",
                "Put the plastic bottle inside the clothes \nyou don't wear and wrap it up.",
                R.drawable.onboarding2,
            )
            2 -> OnBoardingFragment.newInstance(
                "Draw an angry man",
                "Draw an angry man on your clothes or pillow \nusing tape or pen.",
                R.drawable.onboarding3,
            )
            else -> OnBoardingFragment.newInstance(
                "Ready",
                "Please press the location marked in red!",
                R.drawable.onboarding4,
            )
        }
    }

    override fun getItemCount(): Int {
        return 4
    }
}
