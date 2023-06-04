package com.example.cpr2u_android.presentation.education

import android.os.Bundle
import android.view.View
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentPoseResult1Binding
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel

class PoseResult1Fragment :
    BaseFragment<FragmentPoseResult1Binding>(R.layout.fragment_pose_result_1) {
    private val educationViewModel: EducationViewModel by sharedViewModel()
    var isPassed = true
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.tvScore.text = educationViewModel.postPracticeScore.toString()
        if (educationViewModel.postPracticeScore > 80) {
            isPassed = true
            binding.tvScoreDesc.text = "Congratulations!\nYou passed the CPR posture test."
        } else {
            isPassed = false
            binding.tvScoreDesc.text = "You failed the CPR posture test."
        }
    }
}
