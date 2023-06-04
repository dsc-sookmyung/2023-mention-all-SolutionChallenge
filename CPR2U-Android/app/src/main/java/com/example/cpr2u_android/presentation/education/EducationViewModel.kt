package com.example.cpr2u_android.presentation.education

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.cpr2u_android.data.model.response.education.QuizzesListData
import com.example.cpr2u_android.domain.model.UserInfo
import com.example.cpr2u_android.domain.repository.education.EducationRepository
import com.example.cpr2u_android.util.UiState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import timber.log.Timber

class EducationViewModel(private val educationRepository: EducationRepository) : ViewModel() {
    private val _testUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val testUIState: StateFlow<UiState<Boolean>> = _testUIState

    private val _quizzesUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val quizzesUIState: StateFlow<UiState<Boolean>> = _quizzesUIState

    private val _quizProgressUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val quizProgressUIState: StateFlow<UiState<Boolean>> = _quizProgressUIState

    private val _exercisesProgressUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val exercisesProgressUIState: StateFlow<UiState<Boolean>> = _exercisesProgressUIState

    private val _userInfoUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val userInfoUIState: StateFlow<UiState<Boolean>> = _userInfoUIState

    private var _quizzesList = listOf<QuizzesListData>()
    val quizzesList = _quizzesList

    var question: String = ""
    var correct: Boolean = false
    var index: Int = 0
    var correctCount: Int = 0

    var armAngle: ResultMsg = ResultMsg(-1, "", "")
    var compressionRate: ResultMsg = ResultMsg(-1, "", "")
    var pressDepth: ResultMsg = ResultMsg(-1, "", "")
    var postPracticeScore: Int = -1

    var _userInfo = MutableLiveData<UserInfo>()

    //    var _userInfo = MutableLiveData<UserInfo>(-1,-1, -1, -1, -1, "", "", -1.0)
    var userInfo: LiveData<UserInfo> = _userInfo
    fun postLectureId() = viewModelScope.launch {
        kotlin.runCatching {
//            _testUIState.emit(UiState.Loading)
            educationRepository.postLectureId(1)
        }.onSuccess {
            Timber.d("post-lecture-id-success $it")
            _testUIState.emit(UiState.Success(true))
        }.onFailure {
            Timber.d("post-lecture-id-fail $it")
            _testUIState.emit(UiState.Failure("$it"))
        }
    }

    fun getQuizzes() = viewModelScope.launch {
        kotlin.runCatching {
            educationRepository.getQuizzes()
        }.onSuccess {
            Timber.d("get-quizzes-success -> ${it.data}")
            _quizzesList = it.data
            _quizzesUIState.emit(UiState.Success(true))
        }.onFailure {
            _quizzesUIState.emit(UiState.Failure("$it"))
            Timber.d("get-quizzes-fail -> $it")
        }
    }

    fun postQuizProgress() = viewModelScope.launch {
        kotlin.runCatching {
            educationRepository.postQuizProgress(100)
        }.onSuccess {
            Timber.d("post-quiz-progress-success -> $it")
            _quizProgressUIState.emit(UiState.Success(true))
        }.onFailure {
            Timber.d("post-quiz-progress-fail -> $it")
            _quizProgressUIState.emit(UiState.Failure("$it"))
        }
    }

    fun postExercisesProgress(score: Int) = viewModelScope.launch {
        kotlin.runCatching {
            educationRepository.postExercisesProgress(score)
        }.onSuccess {
            Timber.d("post-exercises-success -> $it")
            _exercisesProgressUIState.emit(UiState.Success(true))
        }.onFailure {
            Timber.d("post-exercises-fail -> $it")
            _exercisesProgressUIState.emit(UiState.Failure("$it"))
        }
    }

    fun getInitQuizzesList(): List<QuizzesListData> {
        return _quizzesList
    }

    fun getUserInfo() = viewModelScope.launch {
        kotlin.runCatching {
            educationRepository.getUserInfo()
        }.onSuccess {
            _userInfo.value = UserInfo(
                nickname = it.data.nickname,
                angelStatus = it.data.angelStatus,
                progressPercent = it.data.progressPercent,
                isLectureCompleted = it.data.isLectureCompleted,
                isQuizCompleted = it.data.isQuizCompleted,
                isPostureCompleted = it.data.isPostureCompleted,
                daysLeftUntilExpiration = it.data.daysLeftUntilExpiration,
            )
            _userInfoUIState.emit(UiState.Success(true))
            Timber.d("get-user-info-success -> $it")
            Timber.d("viewmodel userInfo -> $_userInfo")
        }.onFailure {
            Timber.d("get-user-info-fail -> $it")
            _userInfoUIState.emit(UiState.Failure("$it"))
        }
    }

    fun getAddress() = viewModelScope.launch {
        kotlin.runCatching {
            educationRepository.getAddress()
        }.onSuccess {
            Timber.d("get-address-success -> ${it.status}")
        }.onFailure {
            Timber.d("get-address-fail -> $it")
        }
    }
}
