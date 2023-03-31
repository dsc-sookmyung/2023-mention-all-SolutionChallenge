package com.example.cpr2u_android.presentation.education

import android.content.pm.ActivityInfo
import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.findNavController
import androidx.viewpager2.widget.ViewPager2
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentPosePractice1Binding
import com.example.cpr2u_android.presentation.base.BaseFragment
import com.google.android.material.tabs.TabLayoutMediator

class PosePractice1Fragment :
    BaseFragment<FragmentPosePractice1Binding>(R.layout.fragment_pose_practice_1) {
    private lateinit var mViewPager: ViewPager2
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT

        binding.buttonNext.setOnClickListener {
            findNavController().navigate(R.id.action_posePractice1Fragment_to_posePractice2Fragment)
        }

        mViewPager = view.findViewById(R.id.viewPager)
        mViewPager.adapter = OnBoardingViewPagerAdapter(fragmentActivity = activity, requireContext())
        TabLayoutMediator(binding.pageIndicator, mViewPager) { _, _ -> }.attach()
        mViewPager.offscreenPageLimit = 1
    }
}
