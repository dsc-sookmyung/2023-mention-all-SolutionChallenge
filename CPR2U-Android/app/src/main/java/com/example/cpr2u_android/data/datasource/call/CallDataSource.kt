package com.example.cpr2u_android.data.datasource.call

import com.example.cpr2u_android.data.model.request.RequestDispatchReport
import com.example.cpr2u_android.data.model.request.education.RequestCall
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.call.ResponseAddress
import com.example.cpr2u_android.data.model.response.call.ResponseCall
import com.example.cpr2u_android.data.model.response.call.ResponseCallList
import com.example.cpr2u_android.data.model.response.call.ResponseDispatch

interface CallDataSource {
    suspend fun postCall(data: RequestCall): ResponseCall
    suspend fun postCallEnd(callId: Int): GeneralResponse
    suspend fun getCallList(): ResponseCallList
    suspend fun postDispatch(callId: Int): ResponseDispatch
    suspend fun postDispatchArrived(dispatchId: Int): GeneralResponse
    suspend fun postDispatchReport(data: RequestDispatchReport): GeneralResponse
}
