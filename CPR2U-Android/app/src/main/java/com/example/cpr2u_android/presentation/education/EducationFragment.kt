package com.example.cpr2u_android.presentation.education

import android.content.Intent
import android.os.Bundle
import android.view.View
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentEducationBinding
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import timber.log.Timber

class EducationFragment : BaseFragment<FragmentEducationBinding>(R.layout.fragment_education) {
    private val educationViewModel: EducationViewModel by sharedViewModel()
    private var pass1 = false
    private var pass2 = false
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        educationViewModel.getUserInfo()
        initClickListener()
        observeUserInfo()
    }

    private fun initClickListener() {
        binding.clLecture.setOnClickListener {
            startActivity(Intent(requireContext(), LectureActivity::class.java))
        }

        binding.clQuiz.setOnClickListener {
            if (pass1) startActivity(Intent(requireContext(), QuizActivity::class.java))
        }

        binding.clPosturePractice.setOnClickListener {
            if (pass2) startActivity(Intent(requireContext(), PosePracticeActivity::class.java))
        }
    }

    private fun observeUserInfo() {
        educationViewModel.userInfo.observe(viewLifecycleOwner) {
            binding.tvNickname.text = it.nickname
            if (it.isLectureCompleted == 0) {
                binding.done1 = false
            } else {
                binding.done1 = true
                pass1 = true
            }
            if (it.isQuizCompleted == 0) {
                binding.doing2 = educationViewModel.userInfo.value?.isLectureCompleted != 0
                binding.done2 = false
            } else {
                pass2 = true
                binding.doing2 = false
                binding.done2 = true
            }
            if (it.isPostureCompleted == 0) {
                binding.doing3 = educationViewModel.userInfo.value?.isQuizCompleted != 0
                binding.done3 = false
            } else {
                binding.doing3 = false
                binding.done3 = true
            }
            when (it.angelStatus) {
                0 -> {
                    binding.acquired = true
                    binding.tvUserAcquired.text =
                        "ACQUIRED (D-${educationViewModel.userInfo.value!!.daysLeftUntilExpiration})"
                }

                1 -> {
                    binding.acquired = false
                    binding.tvUserAcquired.text = "EXPIRED"
                }

                else -> {
                    binding.acquired = false
                    binding.tvUserAcquired.text = "UNACQUIRED"
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        educationViewModel.getUserInfo()
    }
}
