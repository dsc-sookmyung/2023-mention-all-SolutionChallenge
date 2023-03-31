package com.example.cpr2u_android.domain.repository.call

import com.example.cpr2u_android.data.model.request.RequestDispatchReport
import com.example.cpr2u_android.data.model.request.education.RequestCall
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.call.ResponseAddress
import com.example.cpr2u_android.data.model.response.call.ResponseCall
import com.example.cpr2u_android.data.model.response.call.ResponseCallList
import com.example.cpr2u_android.data.model.response.call.ResponseDispatch

interface CallRepository {
    suspend fun postCall(data: RequestCall): ResponseCall
    suspend fun postCallEnd(callId: Int): GeneralResponse
    suspend fun getCallList(): ResponseCallList
    suspend fun postDispatch(callID: Int): ResponseDispatch
    suspend fun postDispatchArrive(dispatchId: Int): GeneralResponse

    suspend fun postDispatchReport(data: RequestDispatchReport): GeneralResponse

}
