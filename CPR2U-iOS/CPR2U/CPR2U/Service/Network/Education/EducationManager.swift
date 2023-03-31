//
//  EducationManager.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/22.
//

import Foundation

protocol EducationService {
    func saveQuizResult(score: Int) async throws -> (success: Bool, data: QuizResult?)
    func saveLectureProgress(lectureId: Int) async throws -> (success: Bool, data: LectureProgressResult?)
    func savePosturePracticeResult(score: Int) async throws -> (success: Bool, data: PosturePracticeResult?)
    func getEducationProgress() async throws -> (success: Bool, data: UserInfo?)
    func getQuizList() async throws -> (success: Bool, data: [QuizInfo]?)
    func getLecture() async throws -> (success: Bool, data: LectureProgressInfo?)
    func getPostureLecture() async throws -> (success: Bool, data: PostureLectureInfo?)
}

struct EducationManager: EducationService {
    
    private let service: Requestable
    
    init(service: Requestable) {
        self.service = service
    }
    
    func saveQuizResult(score: Int) async throws -> (success: Bool, data: QuizResult?) {
        let request = EducationEndPoint
            .saveQuizResult(score: score)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func saveLectureProgress(lectureId: Int) async throws -> (success: Bool, data: LectureProgressResult?) {
        let request = EducationEndPoint
            .saveLectureProgress(lectureId: lectureId)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func savePosturePracticeResult(score: Int) async throws -> (success: Bool, data: PosturePracticeResult?) {
        let request = EducationEndPoint
            .savePosturePracticeResult(score: score)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func getEducationProgress() async throws -> (success: Bool, data: UserInfo?) {
        let request = EducationEndPoint
            .getEducationProgress
            .createRequest()
        return try await self.service.request(request)
    }
    
    func getQuizList() async throws -> (success: Bool, data: [QuizInfo]?) {
        let request = EducationEndPoint
            .getQuizList
            .createRequest()
        return try await self.service.request(request)
    }
    
    func getLecture() async throws -> (success: Bool, data: LectureProgressInfo?) {
        let request = EducationEndPoint
            .getLecture
            .createRequest()
        return try await self.service.request(request)
    }
    
    func getPostureLecture() async throws -> (success: Bool, data: PostureLectureInfo?) {
        let request = EducationEndPoint
            .getPostureLecture
            .createRequest()
        return try await self.service.request(request)
    }
}
