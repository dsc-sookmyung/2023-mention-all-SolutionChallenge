package com.example.cpr2u_android.presentation.education

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.lifecycle.flowWithLifecycle
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.example.cpr2u_android.R
import com.example.cpr2u_android.data.model.response.education.QuizzesListData
import com.example.cpr2u_android.databinding.FragmentQuizQuestionBinding
import com.example.cpr2u_android.presentation.base.BaseFragment
import com.example.cpr2u_android.util.UiState
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import timber.log.Timber

class QuizQuestionFragment :
    BaseFragment<FragmentQuizQuestionBinding>(R.layout.fragment_quiz_question) {
    private val educationViewModel: EducationViewModel by sharedViewModel()
    private var quizzesList: List<QuizzesListData> = listOf(QuizzesListData(-1, "", -1, -1, "", listOf()),)
    private var quizQuestion: String = ""
    private var selectIndex: Int = -1
    private var answer: Int = -1
    private var isSelected: Boolean = false
    private lateinit var tvChoose4List: List<TextView>
    private lateinit var tvChooseOXList: List<TextView>
    private var choose4Index: ArrayList<Int> = arrayListOf()
    private var chooseOXIndex: ArrayList<Int> = arrayListOf()
    private var choose4Content: ArrayList<String> = arrayListOf("")

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initSelectList()
        observeQuizzesUiState()
        initButtonClickListener()
    }

    private fun observeQuizzesUiState() {
        educationViewModel.quizzesUIState.flowWithLifecycle(lifecycle).onEach {
            when (it) {
                is UiState.Success -> {
                    quizzesList = educationViewModel.getInitQuizzesList()
                    setQuizInfo()
                }
                else -> {}
            }
        }.launchIn(lifecycleScope)
    }

    private fun initSelectList() {
        tvChoose4List =
            listOf(binding.tvChoose1, binding.tvChoose2, binding.tvChoose3, binding.tvChoose4)
        tvChooseOXList = listOf(binding.tvQO, binding.tvQX)
    }

    private fun setQuizInfo() {
        binding.tvQNum.text = "Q.${educationViewModel.index + 1}"
        quizQuestion = quizzesList[educationViewModel.index].question
        binding.tvQ.text = quizzesList[educationViewModel.index].question
        answer = quizzesList[educationViewModel.index].answer

        if (quizzesList[educationViewModel.index].type == 0) {
            binding.clOX.visibility = View.VISIBLE
            binding.clChoose4.visibility = View.INVISIBLE
        } else {
            binding.clOX.visibility = View.INVISIBLE
            binding.clChoose4.visibility = View.VISIBLE
        }

        when (quizzesList[educationViewModel.index].type) {
            0 -> {
                for (i in 0 until quizzesList[educationViewModel.index].answerList.size) {
                    chooseOXIndex.add(quizzesList[educationViewModel.index].answerList[i].id)
                    tvChooseOXList[i].setOnClickListener {
                        isSelected = true
                        it.isSelected = true

                        selectIndex = chooseOXIndex[i]
                        Timber.d("selectIndex -> $selectIndex")
                        val notSelected = tvChooseOXList.filterNot { it == tvChooseOXList[i] }
                        notSelected.forEach {
                            it.isSelected = false
                        }
                    }
                }
            }
            1 -> {
                for (i in 0 until quizzesList[educationViewModel.index].answerList.size) {
                    choose4Index.add(quizzesList[educationViewModel.index].answerList[i].id)
                    tvChoose4List[i].text =
                        quizzesList[educationViewModel.index].answerList[i].content
                    tvChoose4List[i].setOnClickListener { it ->
                        isSelected = true
                        it.isSelected = true
                        selectIndex = choose4Index[i]
                        val notSelected = tvChoose4List.filterNot { it == tvChoose4List[i] }
                        notSelected.forEach {
                            it.isSelected = false
                        }
                    }
                }
            }
        }
    }

    private fun initButtonClickListener() {
        binding.buttonNext.setOnClickListener {
            if (isSelected) {
                val correct = selectIndex == answer
                educationViewModel.question = quizQuestion
                if (correct) educationViewModel.correctCount++
                educationViewModel.correct = correct
                educationViewModel.index = educationViewModel.index + 1
                findNavController().navigate(R.id.action_QuizQuestionFragment_to_QuizAnswerFragment)
            }
        }
    }
}
