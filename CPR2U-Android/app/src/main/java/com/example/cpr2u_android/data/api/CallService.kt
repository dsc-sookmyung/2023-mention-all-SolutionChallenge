package com.example.cpr2u_android.data.api

import com.example.cpr2u_android.data.model.request.RequestDispatchReport
import com.example.cpr2u_android.data.model.request.education.RequestCall
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.call.ResponseCall
import com.example.cpr2u_android.data.model.response.call.ResponseCallList
import com.example.cpr2u_android.data.model.response.call.ResponseDispatch
import com.example.cpr2u_android.data.model.response.call.ResponseNumbersOfAngel
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path

interface CallService {

    @POST("/call")
    suspend fun postCall(
        @Body body: RequestCall,
    ): ResponseCall

    @POST("/call/end/{call_id}")
    suspend fun postCallEnd(
        @Path("call_id") call_id: Int,
    ): GeneralResponse

    @GET("/call/{call_id}")
    suspend fun getNumbersOfAngel(
        @Path("call_id") call_id: Int,
    ): ResponseNumbersOfAngel

    @GET("/call")
    suspend fun getCallList(): ResponseCallList

    @POST("/dispatch")
    suspend fun postDispatch(
        @Body cpr_call_id: Int,
    ): ResponseDispatch

    @POST("/dispatch/arrive/{dispatch_id}")
    suspend fun postDispatchArrive(
        @Path("dispatch_id") dispatch_id: Int,
    ): GeneralResponse

    @POST("/dispatch/report")
    suspend fun postDispatchReport(
        @Body data: RequestDispatchReport,
    ): GeneralResponse
}
