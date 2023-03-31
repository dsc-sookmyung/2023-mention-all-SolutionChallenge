package com.example.cpr2u_android.presentation.call

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.cpr2u_android.data.model.request.RequestDispatchReport
import com.example.cpr2u_android.data.model.request.education.RequestCall
import com.example.cpr2u_android.data.model.response.call.ResponseCallList
import com.example.cpr2u_android.domain.repository.call.CallRepository
import com.example.cpr2u_android.util.UiState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import timber.log.Timber

class CallViewModel(private val callRepository: CallRepository) : ViewModel() {

    var _callId = -1
    private val _callUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val callUIState: StateFlow<UiState<Boolean>> = _callUIState

    private val _callEndUIState = MutableStateFlow<UiState<Boolean>>(UiState.Loading)
    val callEndUIState: StateFlow<UiState<Boolean>> = _callEndUIState

    private val _callEndSuccess = MutableLiveData<Boolean>()
    val callEndSuccess: LiveData<Boolean> = _callEndSuccess

    private val _dispatchSuccess = MutableLiveData<Boolean>()
    val dispatchSuccess: LiveData<Boolean> = _dispatchSuccess

    private val _dispatchArriveSuccess = MutableLiveData<Boolean>()
    val dispatchArriveSuccess: LiveData<Boolean> = _dispatchArriveSuccess

    private val _dispatchReportSuccess = MutableLiveData<Boolean>()
    val dispatchReportSuccess: LiveData<Boolean> = _dispatchReportSuccess

    private val _callListInfo = MutableLiveData<ResponseCallList>()
    val callListInfo: LiveData<ResponseCallList> = _callListInfo

    private val _dispatchId = MutableLiveData<Int>()
    val dispatchId: LiveData<Int> = _dispatchId

    /*
    "latitude": 37.5440261,
  "longitude": 126.9671087,
  "full_address": "서울특별시 용산구 청파동3가 114-11"
     */
    fun postCall(latitude: Double, longitude: Double, address: String) = viewModelScope.launch {
        kotlin.runCatching {
            _callUIState.emit(UiState.Loading)
            val edit_address = address.substring(5, address.length)
            Timber.d("latitude -> $latitude, Longitude -> $longitude, address -> $edit_address")
            callRepository.postCall(
                data = RequestCall(
                    latitude = latitude,
                    longitude = longitude,
                    fullAddress = edit_address,
                ),
            )
        }.onSuccess {
            Timber.d("post-call-success $it")
            _callId = it.data.callId
            _callUIState.emit(UiState.Success(true))
            Timber.d("set call ID -> $_callId")
        }.onFailure {
            _callUIState.emit(UiState.Failure("$it"))
            Timber.d("post-call-fail $it")
        }
    }

    fun setCallUiState() = viewModelScope.launch {
        kotlin.runCatching {
            _callUIState.emit(UiState.Loading)
        }
    }

    fun postCallEnd(callId: Int) = viewModelScope.launch {
        kotlin.runCatching {
            _callEndUIState.emit(UiState.Loading)
            Timber.d("_callID -> $callId")
            callRepository.postCallEnd(callId)
        }.onSuccess {
            _callEndSuccess.value = true
            _callEndUIState.emit(UiState.Success(true))
            Timber.d("post-call-end-success $it")
        }.onFailure {
            _callEndSuccess.value = false
            _callEndUIState.emit(UiState.Failure("$it"))
            Timber.d("post-call-end-fail $it")
        }
    }

    fun getCallList() = viewModelScope.launch {
        kotlin.runCatching {
            callRepository.getCallList()
        }.onSuccess {
            Timber.d("get-call-list-success -> $it")
            it.data.callList
            _callListInfo.value = it
            Timber.d("_call List Info -> ${_callListInfo.value}")
        }.onFailure {
            Timber.d("get-call-list-fail -> $it")
        }
    }

    fun postDispatch(callId: Int) = viewModelScope.launch {
        kotlin.runCatching {
            Timber.d("dispatch call id -> $callId")
            callRepository.postDispatch(callId)
        }.onSuccess {
            _dispatchSuccess.value = true
            _dispatchId.value = it.data.dispatchId
            Timber.d("set dispatch ID -> ${_dispatchId.value}")
            Timber.d("post-dispatch-success -> $it")
        }.onFailure {
            _dispatchSuccess.value = false
            Timber.d("post-dispatch-fail -> $it")
        }
    }

    fun postDispatchArrive() = viewModelScope.launch {
        kotlin.runCatching {
            Timber.d("dispatch Id -> ${_dispatchId.value}")
            callRepository.postDispatchArrive(_dispatchId.value!!)
        }.onSuccess {
            Timber.d("post-dispatch-arrive-success -> $it")
            _dispatchArriveSuccess.value = true
        }.onFailure {
            Timber.d("post-dispatch-arrive-fail -> $it")
            _dispatchArriveSuccess.value = false
        }
    }

    fun postDispatchReport(dispatchId: Int, content: String) = viewModelScope.launch {
        kotlin.runCatching {
            Timber.d("report id -> $dispatchId")
            Timber.d("content -> $content")
            callRepository.postDispatchReport(
                RequestDispatchReport(
                    content = content,
                    dispatchId = dispatchId,
                ),
            )
        }.onSuccess {
            Timber.d("post-dispatch-report-success -> $it")
            _dispatchReportSuccess.value = true
        }.onFailure {
            Timber.d("post-dispatch-report-fail -> $it")
            _dispatchReportSuccess.value = false
        }
    }
}
