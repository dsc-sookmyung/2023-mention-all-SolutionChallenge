package com.example.cpr2u_android.data.repository.education

import com.example.cpr2u_android.data.datasource.education.EducationDataSource
import com.example.cpr2u_android.data.model.response.auth.GeneralResponse
import com.example.cpr2u_android.data.model.response.call.ResponseAddress
import com.example.cpr2u_android.data.model.response.education.ResponseQuizzesList
import com.example.cpr2u_android.data.model.response.education.ResponseUserInfo
import com.example.cpr2u_android.domain.repository.education.EducationRepository
import timber.log.Timber

class EducationRepositoryImpl(private val educationDataSource: EducationDataSource) :
    EducationRepository {
    override suspend fun postLectureId(lectureId: Int): GeneralResponse {
        Timber.d("repository Impl ID -> $lectureId")
        return educationDataSource.postLectureId(lectureId)
    }

    override suspend fun getQuizzes(): ResponseQuizzesList {
        return educationDataSource.getQuizzes()
    }

    override suspend fun postQuizProgress(score: Int): GeneralResponse {
        return educationDataSource.postQuizProgress(score)
    }

    override suspend fun postExercisesProgress(score: Int): GeneralResponse {
        return educationDataSource.postExercisesProgress(score)
    }

    override suspend fun getUserInfo(): ResponseUserInfo {
        return educationDataSource.getUserInfo()
    }

    override suspend fun getAddress(): ResponseAddress {
        return educationDataSource.getAddress()
    }
}
