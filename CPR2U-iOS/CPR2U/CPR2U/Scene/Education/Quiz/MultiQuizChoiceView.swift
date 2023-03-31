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
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 26
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        choices.forEach({
            stackView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            $0.widthAnchor.constraint(equalToConstant: 334).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 260)
        ])
        
        NSLayoutConstraint.activate([
            choices[0].topAnchor.constraint(equalTo: stackView.topAnchor),
            choices[1].topAnchor.constraint(equalTo: choices[0].bottomAnchor, constant: 26),
            choices[2].topAnchor.constraint(equalTo: choices[1].bottomAnchor, constant: 26),
            choices[3].topAnchor.constraint(equalTo: choices[2].bottomAnchor, constant: 26)
        ])
        
        answerCenterPosition = choices[1].center
    }
    
    override func setUpStyle() {
        choices.forEach({
            $0.backgroundColor = UIColor.mainRed.withAlphaComponent(0.05)
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.mainRed.cgColor
            $0.layer.cornerRadius = 20
            $0.titleLabel?.font = UIFont(weight: .regular, size: 26)
            $0.titleLabel?.minimumScaleFactor = 0.15
            $0.titleLabel?.numberOfLines = 1
            $0.titleLabel?.adjustsFontSizeToFitWidth = true
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
