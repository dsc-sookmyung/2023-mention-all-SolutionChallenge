package com.example.cpr2u_android.presentation.education

import android.os.Bundle
import android.view.View
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentPoseResult2Binding
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel

class PoseResult2Fragment :
    BaseFragment<FragmentPoseResult2Binding>(R.layout.fragment_pose_result_2) {
    private val educationViewModel: EducationViewModel by sharedViewModel()
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.tvCompressionResult.text = educationViewModel.compressionRate.title
        binding.tvCompressionRateDesc.text = educationViewModel.compressionRate.desc

        binding.tvArmResult.text = educationViewModel.armAngle.title
        binding.tvArmDesc.text = educationViewModel.armAngle.desc

        binding.tvPressResult.text = educationViewModel.pressDepth.title
        binding.tvPressDesc.text = educationViewModel.pressDepth.desc
    }
}
