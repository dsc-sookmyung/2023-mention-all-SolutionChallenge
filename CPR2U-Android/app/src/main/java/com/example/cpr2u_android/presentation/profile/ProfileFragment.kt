package com.example.cpr2u_android.presentation.profile

import android.os.Bundle
import android.view.View
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentProfileBinding
import com.example.cpr2u_android.presentation.base.BaseFragment
import com.example.cpr2u_android.presentation.education.EducationViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

class ProfileFragment : BaseFragment<FragmentProfileBinding>(R.layout.fragment_profile) {
    private val educationViewModel: EducationViewModel by viewModel()
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        educationViewModel.getUserInfo()
        educationViewModel.userInfo.observe(viewLifecycleOwner) {
            // 닉네임 설정
            binding.tvNickname.text = "Hi ${educationViewModel.userInfo.value?.nickname}"
            // 이미지 설정
            when (educationViewModel.userInfo.value?.angelStatus) {
                0 -> {
                    binding.acquired = true
                    binding.tvUserCertificationText2.text =
                        "ACQUIRED (D-${educationViewModel.userInfo.value!!.daysLeftUntilExpiration})"

                    // 프로그래스바 설정
                    val progress =
                        ((90 - educationViewModel.userInfo.value?.daysLeftUntilExpiration!!) % 100).toInt()
                    binding.progressBarExpirationPeriod.progress = progress

                    val sdf = SimpleDateFormat("yyyy.MM.dd")
                    val c: Calendar = Calendar.getInstance()
                    try {
                        c.setTime(Calendar.getInstance().time)
                    } catch (e: ParseException) {
                        e.printStackTrace()
                    }
                    c.add(
                        Calendar.DATE,
                        educationViewModel.userInfo.value!!.daysLeftUntilExpiration,
                    )
                    binding.tvDate.text = sdf.format(c.time)
                }
                1 -> {
                    binding.acquired = false
                    binding.tvUserCertificationText2.text = "EXPIRED"
                }
                else -> {
                    binding.acquired = false
                    binding.tvUserCertificationText2.text = "UNACQUIRED"
                }
            }
        }
    }
}
