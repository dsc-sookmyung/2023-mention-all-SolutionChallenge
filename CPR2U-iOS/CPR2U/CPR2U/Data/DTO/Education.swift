//
//  Education.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/22.
//

import Foundation

struct QuizResult: Codable { }

struct LectureProgressResult: Codable { }

struct PosturePracticeResult: Codable { }

struct UserInfo: Codable {
    let nickname: String
    let angel_status: Int
    let progress_percent: Double
    let is_lecture_completed: Int
    let is_quiz_completed: Int
    let is_posture_completed: Int
    let days_left_until_expiration: Int?
}

struct QuizInfo: Codable {
    let index: Int
    let question: String
    let type: Int
    let answer: Int
    let reason: String
    let answer_content: String
    let answer_list: [AnswerInfo]
}

struct AnswerInfo: Codable {
    let id: Int
    let content: String
}

struct LectureProgressInfo: Codable {
    let current_step: Int
    let lecture_list: [LectureInfo]
}

struct LectureInfo: Codable {
    let id: Int
    let step: Int
    let title: String
    let description: String
    let video_url: String
}

struct PostureLectureInfo: Codable {
    let video_url: String
}
