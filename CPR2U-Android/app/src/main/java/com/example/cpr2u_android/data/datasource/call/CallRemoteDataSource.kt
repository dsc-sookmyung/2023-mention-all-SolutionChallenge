package com.example.cpr2u_android.data.datasource.call

import com.example.cpr2u_android.data.api.CallService
import com.example.cpr2u_android.data.model.request.RequestDispatchReport
import com.example.cpr2u_android.data.model.request.education.RequestCall
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.call.ResponseCall
import com.example.cpr2u_android.data.model.response.call.ResponseCallList
import com.example.cpr2u_android.data.model.response.call.ResponseDispatch
import com.example.cpr2u_android.data.model.response.call.ResponseNumbersOfAngel
import timber.log.Timber

class CallRemoteDataSource(private val callService: CallService) : CallDataSource {
    override suspend fun postCall(data: RequestCall): ResponseCall {
        return callService.postCall(data)
    }

    override suspend fun postCallEnd(callId: Int): GeneralResponse {
        Timber.d("data call Id -> $callId")
        return callService.postCallEnd(callId)
    }

    override suspend fun getNumbersOfAngel(callId: Int): ResponseNumbersOfAngel {
        return callService.getNumbersOfAngel(callId)
    }

    override suspend fun getCallList(): ResponseCallList {
        return callService.getCallList()
    }

    override suspend fun postDispatch(callId: Int): ResponseDispatch {
        return callService.postDispatch(callId)
    }

    override suspend fun postDispatchArrived(dispatchId: Int): GeneralResponse {
        return callService.postDispatchArrive(dispatchId)
    }

    override suspend fun postDispatchReport(data: RequestDispatchReport): GeneralResponse {
        return callService.postDispatchReport(data)
    }
}
