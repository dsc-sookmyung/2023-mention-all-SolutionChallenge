//
//  MultiQuizChoiceView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/18.
//

import UIKit

final class MultiQuizChoiceView: QuizChoiceView {
    
    private var answerCenterPosition = CGPoint()
    private var defaultPosition = CGPoint()
    private var selectedChoice = UIButton()
    
    init (viewModel: QuizViewModel) {
        super.init(quizType: .multi, viewModel: viewModel)
        
        setUpConstraints()
        setUpText()
        setUpStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(quizType: QuizType, viewModel: QuizViewModel) {
        fatalError("init(quizType:viewModel:) has not been implemented")
    }
    
    override func setUpConstraints() {
        let make = Constraints.shared
        
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 26
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space12),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space12)
        ])
        
        choices.forEach({
            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
            $0.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        })
        answerCenterPosition = choices[1].center
    }
    
    override func setUpStyle() {
        choices.forEach({
            $0.backgroundColor = UIColor.mainRed.withAlphaComponent(0.05)
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.mainRed.cgColor
            $0.layer.cornerRadius = 20
            $0.titleLabel?.font = UIFont(weight: .regular, size: 26)
            $0.titleLabel?.numberOfLines = 1
            $0.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
            $0.setTitleColor(.mainBlack, for: .normal)
        })
    }
    
    override func animateChoiceButton(answerIndex: Int) {
        var otherButtons: [UIButton] = []
        for index in 0..<choices.count {
            if index != answerIndex {
                otherButtons.append(choices[index])
            }
        }
        
        defaultPosition = choices[answerIndex].center
        selectedChoice = choices[answerIndex]
        UIView.animate(withDuration: 0.3, animations: { [self] in
            otherButtons.forEach({ $0.alpha = 0.0})
            choices[answerIndex].center = choices[1].center
            layoutIfNeeded()
        })
    }
    
    override func resetChoiceButtonConstraint() {
        choices.forEach({ $0.alpha = 1.0 })
        selectedChoice.center = defaultPosition
    }
}
