//
//  Quiz.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/14.
//

import Foundation

enum QuizType: Int {
    case ox = 2
    case multi = 4
}

struct Quiz {
    let questionType:QuizType
    let questionNumber: Int
    let question: String
    let answerIndex: Int
    let answerList: [String]
    let answerDescription: String
}
