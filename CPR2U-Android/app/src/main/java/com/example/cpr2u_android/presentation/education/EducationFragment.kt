package com.example.cpr2u_android.presentation.education

import android.app.Dialog
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import androidx.databinding.DataBindingUtil
import com.example.cpr2u_android.R
import com.example.cpr2u_android.data.sharedpref.CPR2USharedPreference
import com.example.cpr2u_android.databinding.DialogQuizBinding
import com.example.cpr2u_android.databinding.DialogSelectAddressBinding
import com.example.cpr2u_android.databinding.FragmentEducationBinding
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel

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
            if (pass2)startActivity(Intent(requireContext(), PosePracticeActivity::class.java))
        }
    }

    private fun observeUserInfo() {
        educationViewModel.userInfo.observe(viewLifecycleOwner) {
            if (educationViewModel.userInfo.value?.isLectureCompleted == 2) {
                binding.clLecture.isSelected = true
                pass1 = true
                binding.tvLectureComplete.text = "Complete"
            } else {
                binding.clLecture.isSelected = false
                binding.tvLectureComplete.text = "Not Completed"
            }

            if (educationViewModel.userInfo.value?.isQuizCompleted == 2) {
                binding.clQuiz.isSelected = true
                pass2 = true
                binding.tvQuizComplete.text = "Complete"
            } else {
                binding.clQuiz.isSelected = false
                binding.tvQuizComplete.text = "Not Completed"
            }

            if (educationViewModel.userInfo.value?.isPostureCompleted == 2) {
                binding.clPosturePractice.isSelected = true
                binding.tvPosePracticeComplete.text = "Complete"
            } else {
                binding.clPosturePractice.isSelected = false
                binding.tvPosePracticeComplete.text = "Not Completed"
            }

            if (educationViewModel.userInfo.value?.angelStatus == 2 && CPR2USharedPreference.getLocation()
                    .isNullOrEmpty()
            ) {
                // 주소 피커 띄우기
                val dialog = Dialog(requireContext())
                val dialogBinding = DataBindingUtil.inflate<DialogSelectAddressBinding>(
                    LayoutInflater.from(requireContext()),
                    R.layout.dialog_select_address,
                    null,
                    false,
                )
                dialogBinding.npSido.apply {
                    // TODO : 주소 max value, display value
                    setOnValueChangedListener { picker, oldVal, newVal ->

                    }
                }
            }

            binding.progressBar.progress =
                (educationViewModel._userInfo.value?.progressPercent!! * 100).toInt()
            binding.tvNickname.text = educationViewModel._userInfo.value?.nickname

            when (educationViewModel.userInfo.value?.angelStatus) {
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
