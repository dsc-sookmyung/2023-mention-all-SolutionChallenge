package com.example.cpr2u_android.presentation.auth

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.cpr2u_android.data.model.request.auth.RequestLogin
import com.example.cpr2u_android.data.model.request.auth.RequestSignUp
import com.example.cpr2u_android.data.sharedpref.CPR2USharedPreference
import com.example.cpr2u_android.domain.repository.auth.AuthRepository
import com.example.cpr2u_android.util.UiState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import timber.log.Timber

class AuthViewModel(private val authRepository: AuthRepository) : ViewModel() {
    private var _phoneNumber: String = ""
    val phoneNumber: String
        get() = _phoneNumber

    private var _nickname: String = ""
    val nickname: String
        get() = _nickname

    private val _validationCode = MutableLiveData<String>()
    var validationCode: LiveData<String> = _validationCode

    private val _isUser = MutableLiveData<Boolean>()
    var isUser: LiveData<Boolean> = _isUser

    private val _isValidNickname = MutableLiveData<Boolean>()
    var isValidNickname: LiveData<Boolean> = _isValidNickname

    private val _isSuccess = MutableLiveData<Boolean>()
    var isSuccess: LiveData<Boolean> = _isSuccess

    private val _logoutUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val logoutUIState: StateFlow<UiState<Boolean>> = _logoutUIState

    fun setPhoneNumber(phoneNumber: String) {
        Timber.d("### set phone number -> $phoneNumber")
        _phoneNumber = phoneNumber
    }

    fun setNickname(nickname: String) {
        _nickname = nickname
    }
    fun postVerification(phoneNumber: String) = viewModelScope.launch {
        kotlin.runCatching {
            authRepository.postVerification(phoneNumber)
        }.onSuccess {
            Timber.d("validation code success -> ${it.data.validationCode}")
            _validationCode.value = it.data.validationCode
            Timber.d("validation code success set -> ${_validationCode.value}")
        }.onFailure {
            Timber.e("validation code fail $it")
        }
    }

    fun postLogin(loginData: RequestLogin) = viewModelScope.launch {
        kotlin.runCatching {
            authRepository.postLogin(loginData)
        }.onSuccess {
            Timber.d("인증된 사용자. 메인화면으로")
            _isUser.value = true
            CPR2USharedPreference.setAccessToken(it.data.accessToken)
            CPR2USharedPreference.setRefreshToken(it.data.refreshToken)
        }.onFailure {
            Timber.d("인증되지 않은 사용자. 회원가입 필요 $it")
            _isUser.value = false
        }
    }

    fun getValidNickname(nickname: String) = viewModelScope.launch {
        kotlin.runCatching {
            authRepository.getNickname(nickname)
        }.onSuccess {
            Timber.d("사용 가능한 닉네임")
            setIsValidNickname(true)
        }.onFailure {
            Timber.d("사용 불가능한 닉네임")
            setIsValidNickname(false)
        }
    }

    fun postSignUp(addressId: Int) = viewModelScope.launch {
        kotlin.runCatching {
            Timber.d("CPR2USharedPreference.getDeviceToken() -> ${CPR2USharedPreference.getDeviceToken()}")
            Timber.d("phonenumber -> $_phoneNumber")
            Timber.d("nickname -> $_nickname")
            authRepository.postSignUp(
                RequestSignUp(
                    deviceToken = CPR2USharedPreference.getDeviceToken(),
                    phoneNumber = _phoneNumber,
                    addressId = addressId,
                    nickname = _nickname,
                ),
            )
        }.onSuccess {
            Timber.e("post-sign-up-success -> $it")
            _isSuccess.value = true
            CPR2USharedPreference.setAccessToken(it.data.accessToken)
            CPR2USharedPreference.setRefreshToken(it.data.refreshToken)
        }.onFailure {
            Timber.e("post-sign-up-fail -> $it")
            _isSuccess.value = false
        }
    }

    private fun setIsValidNickname(isValid: Boolean) {
        Timber.d("set value")
        _isValidNickname.value = isValid
    }

    fun getValidationCode(): String? {
        return _validationCode.value
    }

    fun postLogout() = viewModelScope.launch {
        kotlin.runCatching {
            authRepository.postLogout()
        }.onSuccess {
            CPR2USharedPreference.setAccessToken("")
            CPR2USharedPreference.setRefreshToken("")
            Timber.d("post-logout-success")
            _logoutUIState.emit(UiState.Success(true))
        }.onFailure {
            Timber.d("post-logout-fail -> $it")
            _logoutUIState.emit(UiState.Failure("$it"))
        }
    }
}
