//
//  QuizViewModel.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/14.
//

import Foundation
import Combine

class QuizViewModel: OutputOnlyViewModelType {
    private var eduManager: EducationManager
    private var quizList: [Quiz] = []
    private var currentQuizIndex: Int = 0
    private var didSelectAnswer: Bool = false
    private var correctQuizNum: Int = 0
    var selectedAnswerIndex = CurrentValueSubject<Int, Never>(-1)
    
    init() {
        eduManager = EducationManager(service: APIManager())
    }
    
    struct Output {
        let quiz: CurrentValueSubject<Quiz, Never>?
        let isCorrect: CurrentValueSubject<Bool, Never>?
        let isQuizEnd: CurrentValueSubject<Bool, Never>
    }
     
    func isSelected() {
        didSelectAnswer = true
    }
    
    func isConfirmed() {
        didSelectAnswer = false
    }
    
    func quizInit() -> Quiz {
        return quizList[0]
    }
    
    func currentQuiz() -> Quiz {
        return quizList[currentQuizIndex]
    }
    func currentQuizType() -> QuizType {
        return quizList[currentQuizIndex].questionType
    }
    func updateSelectedAnswerIndex(index: Int) {
        selectedAnswerIndex.send(index)
    }
    
    func quizResultString() -> String {
        return "\(correctQuizNum)/\(quizList.count)"
    }
    
    func isQuizAllCorrect() -> Bool {
        return correctQuizNum == quizList.count
    }
    
    func transform() -> Output {
        
        if selectedAnswerIndex.value == -1 {
            return Output(quiz: nil, isCorrect: nil, isQuizEnd: CurrentValueSubject<Bool, Never>(false))
        }
        
        var output: Output
        
        if didSelectAnswer {
            let index = selectedAnswerIndex.value
            let isCorrect = currentQuiz().answerIndex == index

            if isCorrect {
                correctQuizNum += 1
            }
            output = Output(quiz: nil, isCorrect: CurrentValueSubject(isCorrect), isQuizEnd: CurrentValueSubject<Bool, Never>(false))
            didSelectAnswer.toggle()
        } else {
            currentQuizIndex += 1
            if quizList.count == currentQuizIndex {
                output = Output(quiz: nil, isCorrect: nil, isQuizEnd: CurrentValueSubject<Bool, Never>(true))
            } else {
                output = Output(quiz: CurrentValueSubject(quizList[currentQuizIndex]), isCorrect: nil, isQuizEnd: CurrentValueSubject<Bool, Never>(false))
                selectedAnswerIndex.send(-1)
                didSelectAnswer.toggle()
            }
        }
        return output
    }
    
    func receiveQuizList() async throws {
        let result = Task { () -> [QuizInfo]? in
            let eduResult = try await eduManager.getQuizList()
            return eduResult.data
        }
        
        do {
            let data = try await result.value
            data?.forEach({ item in
                
                guard let answerIndex = item.answer_list.map({ $0.id }).firstIndex(of: item.answer) else { return }
                let answerList = item.answer_list.map { $0.content }
                let quiz = Quiz(questionType: item.type == 0 ? .ox : .multi, questionNumber: item.index, question: item.question, answerIndex: answerIndex, answerList: answerList, answerDescription: item.reason)
                quizList.append(quiz)
            })
        } catch(let error) {
            print(error)
        }
    }

    func saveQuizResult() async throws{
        (_, _) = try await eduManager.saveQuizResult(score: 100)
    }
    
}
