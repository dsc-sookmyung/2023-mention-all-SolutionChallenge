package com.example.cpr2u_android.presentation.education

import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.flowWithLifecycle
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.DialogQuizBinding
import com.example.cpr2u_android.databinding.FragmentQuizAnswerBinding
import com.example.cpr2u_android.presentation.base.BaseFragment
import com.example.cpr2u_android.util.UiState
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import timber.log.Timber

class QuizAnswerFragment : BaseFragment<FragmentQuizAnswerBinding>(R.layout.fragment_quiz_answer) {
    private val educationViewModel: EducationViewModel by sharedViewModel()
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.tvQNum.text = "Q.${educationViewModel.index}"
        binding.tvQ.text = educationViewModel.question
        binding.tvSelectResult.text =
            educationViewModel.correct.toString() // TODO: 서버가 result conte음t로 바꿔준댓음

        binding.tvResult.text = if (educationViewModel.correct) "Correct" else "Incorrect"
        binding.tvSelectResult.isSelected = educationViewModel.correct
        Timber.d("result index -> ${educationViewModel.index}")
        binding.tvExplain.text =
            educationViewModel.getInitQuizzesList()[educationViewModel.index - 1].reason

        binding.buttonSecond.setOnClickListener {
            if (educationViewModel.index == 5) {
                Timber.d("끝")
                // 성공
                val dialog = Dialog(requireContext())
                val binding = DataBindingUtil.inflate<DialogQuizBinding>(
                    LayoutInflater.from(requireContext()),
                    R.layout.dialog_quiz,
                    null,
                    false,
                )

                if (educationViewModel.correctCount == 5) {
                    binding.ivHeart.visibility = View.VISIBLE
                    binding.ivHeartGray.visibility = View.INVISIBLE
                    binding.tvTitle.text = "Congratulation!"
                    binding.tvSubtitle.text = "You have completed the Quiz!\nYou are one step closer to becoming \na CPR Angel!"
                } else {
                    binding.ivHeart.visibility = View.INVISIBLE
                    binding.ivHeartGray.visibility = View.VISIBLE
                    binding.tvTitle.text = "Quiz Failed: ${educationViewModel.correctCount}/5"
                    binding.tvSubtitle.text = "Try Again"
                }

                binding.buttonFinish.setOnClickListener {
                    if (educationViewModel.correctCount == 5) {
                        educationViewModel.postQuizProgress()
                        educationViewModel.quizProgressUIState.flowWithLifecycle(lifecycle).onEach {
                            when (it) {
                                is UiState.Success -> {
                                    Timber.d("success")
                                    dialog.dismiss()
                                    activity?.finish()
                                }
                                else -> {}
                            }
                        }.launchIn(lifecycleScope)
                    } else {
                        dialog.dismiss()
                        activity?.finish()
                    }
                }
                dialog.setContentView(binding.root)
                dialog.window?.setLayout(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                )
                dialog.show()
            } else {
                findNavController().navigate(R.id.action_QuizAnswerFragment_to_QuizQuestionFragment)
            }
        }
    }
}
