package com.example.cpr2u_android.presentation.education

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import androidx.activity.OnBackPressedCallback
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.lifecycle.flowWithLifecycle
import androidx.lifecycle.lifecycleScope
import androidx.viewpager2.adapter.FragmentStateAdapter
import androidx.viewpager2.widget.ViewPager2
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.DialogQuizBinding
import com.example.cpr2u_android.databinding.FragmentPosePractice3Binding
import com.example.cpr2u_android.presentation.base.BaseFragment
import com.example.cpr2u_android.util.UiState
import com.google.android.material.tabs.TabLayoutMediator
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import timber.log.Timber

class PosePractice3Fragment :
    BaseFragment<FragmentPosePractice3Binding>(R.layout.fragment_pose_practice_3) {
    private val educationViewModel: EducationViewModel by sharedViewModel()
    private lateinit var callback: OnBackPressedCallback
    var isPassed = true
    private lateinit var viewPager: ViewPager2
    private lateinit var onboardingAdapter: OnboardingAdapter
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

//        binding.tvCompressionResult.text = educationViewModel.compressionRate.title
//        binding.tvCompressionRateDesc.text = educationViewModel.compressionRate.desc
//
//        binding.tvArmResult.text = educationViewModel.armAngle.title
//        binding.tvArmDesc.text = educationViewModel.armAngle.desc
//
//        binding.tvPressResult.text = educationViewModel.pressDepth.title
//        binding.tvPressDesc.text = educationViewModel.pressDepth.desc
//
//        binding.tvPercentNum.text = educationViewModel.postPracticeScore.toString()
//
        Timber.d("SCORE >> ${educationViewModel.postPracticeScore}")
        isPassed = educationViewModel.postPracticeScore >= 80

        viewPager = view.findViewById(R.id.viewPager)
        onboardingAdapter = OnboardingAdapter(this)

        viewPager.adapter = onboardingAdapter
        TabLayoutMediator(binding.pageIndicator, viewPager) { _, _ -> }.attach()
        viewPager.offscreenPageLimit = 1

        binding.btnQuit.setOnClickListener {
            if (isPassed) {
                // 성공
                val dialog = Dialog(requireContext())
                val binding = DataBindingUtil.inflate<DialogQuizBinding>(
                    LayoutInflater.from(requireContext()),
                    R.layout.dialog_quiz,
                    null,
                    false,
                )
                binding.ivHeart.visibility = View.VISIBLE
                binding.ivHeartGray.visibility = View.VISIBLE
                binding.tvTitle.text = "Congratulation!"
                binding.tvSubtitle.text = "You have got CPR Angel Certificate!\nNow you're a CPR Angel and can help\nsomeone in cardiac arrest."

                binding.buttonFinish.setOnClickListener {
                    educationViewModel.postExercisesProgress(educationViewModel.postPracticeScore)
                    Timber.d("educationViewModel.postPracticeScore -> ${educationViewModel.postPracticeScore}")
                    educationViewModel.exercisesProgressUIState.flowWithLifecycle(lifecycle)
                        .onEach {
                            when (it) {
                                is UiState.Success -> {
                                    Timber.d("success")
                                    dialog.dismiss()
                                    activity?.finish()
                                }
                                else -> {}
                            }
                        }.launchIn(lifecycleScope)
                }
                dialog.setContentView(binding.root)
                dialog.window?.setLayout(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                )
                dialog.show()
            } else { // 실패
                activity?.finish()
            }
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        callback = object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                activity?.finish()
            }
        }
        requireActivity().onBackPressedDispatcher.addCallback(this, callback)
    }

    override fun onDetach() {
        super.onDetach()
        callback.remove()
    }

    inner class OnboardingAdapter(fragment: Fragment) : FragmentStateAdapter(fragment) {
        private val fragmentList: MutableList<Fragment> = ArrayList()

        init {
            // 첫 번째 Fragment를 추가합니다.
            fragmentList.add(PoseResult1Fragment())

            // 두 번째 Fragment를 추가합니다.
            fragmentList.add(PoseResult2Fragment())
        }

        override fun getItemCount(): Int {
            return fragmentList.size
        }

        override fun createFragment(position: Int): Fragment {
            return fragmentList[position]
        }
    }
}
