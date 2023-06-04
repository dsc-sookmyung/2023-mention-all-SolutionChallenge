//
//  QuizChoiceView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import Combine
import CombineCocoa
import UIKit

public class QuizChoiceView: UIView {
    
    public var choices: [UIButton] = []
    private var viewModel: QuizViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    required init(quizType: QuizType, viewModel: QuizViewModel) {
        super.init(frame: CGRect.zero)
        
        for _ in 0..<quizType.rawValue {
            choices.append(UIButton())
        }
        
        self.viewModel = viewModel
        setUpAction()
        bind(quizType: quizType, viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() { }
    func setUpStyle() { }
        
    private func setUpAction() {
        for (index, choice) in choices.enumerated() {
            choice.tapPublisher.sink { [weak self] in
                self?.viewModel?.updateSelectedAnswerIndex(index: index)
            }
            .store(in: &cancellables)
        }
    }
    
    private func bind(quizType: QuizType, viewModel: QuizViewModel) {
        viewModel.selectedAnswerIndex.sink { [weak self] index in
            if index == -1 {
                self?.resetButtonStatus()
            } else {
                guard quizType == viewModel.quiz?.questionType else { return }
                self?.choices[index].changeButtonStyle(isSelected: true)
                let otherChoices = self?.choices.filter { $0 != self?.choices[index] }
                otherChoices?.forEach({
                    $0.changeButtonStyle(isSelected: false)
                })
            }
        }.store(in: &cancellables)
    }
    
    private func resetButtonStatus() {
        for choice in choices {
            choice.changeButtonStyle(isSelected: false)
        }
    }
    
    func setUpText(_ answers: [String]? = nil) {
        if answers == nil {
            choices[0].setTitle("O", for: .normal)
            choices[1].setTitle("X", for: .normal)
        } else {
            for (index, choice) in choices.enumerated() {
                guard let answer = answers?[index] else { return }
                choice.setTitle(answer, for: .normal)
                
                if answer.count > 24 {
                    choice.titleLabel?.font = UIFont(weight: .regular, size: 20)
                } else {
                    choice.titleLabel?.font = UIFont(weight: .regular, size: 26)
                }
            }
        }
    }
    
    func interactionEnabled(to status: Bool) {
        choices.forEach({
            $0.isUserInteractionEnabled = status
        })
    }
    func animateChoiceButton(answerIndex: Int) { }
    func resetChoiceButtonConstraint() { }
}
