//
//  OXQuizChoiceView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/18.
//

import UIKit

final class OXQuizChoiceView: QuizChoiceView {
    
    var oButtonWidthConstraint = NSLayoutConstraint()
    var xButtonWidthConstraint = NSLayoutConstraint()
    init (viewModel: QuizViewModel) {
        super.init(quizType: .ox, viewModel: viewModel)
        
        setUpConstraints()
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
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 44
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        choices.forEach({
            stackView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 80).isActive = true
        })
        
        oButtonWidthConstraint = choices[0].widthAnchor.constraint(equalToConstant: 108)
        xButtonWidthConstraint = choices[1].widthAnchor.constraint(equalToConstant: 108)
        
        NSLayoutConstraint.activate([
            oButtonWidthConstraint,
            xButtonWidthConstraint
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 260),
            stackView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            choices[0].leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            choices[1].trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    override func setUpStyle() {
        choices.forEach({
            $0.backgroundColor = UIColor.mainRed.withAlphaComponent(0.05)
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.mainRed.cgColor
            $0.layer.cornerRadius = 20
            $0.titleLabel?.font = UIFont(weight: .bold, size: 36)
            $0.setTitleColor(.mainBlack, for: .normal)
        })
    }
    
    override func animateChoiceButton(answerIndex: Int) {
        let oChoiceTargetConstraint: CGFloat = answerIndex == 0 ? 260 : 0
        let xChoiceTargetConstraint: CGFloat = answerIndex == 0 ? 0 : 260
        
        UIView.animate(withDuration: 0.3, animations: {
            self.oButtonWidthConstraint.constant = oChoiceTargetConstraint
            self.xButtonWidthConstraint.constant = xChoiceTargetConstraint
            self.layoutIfNeeded()
        })
    }
    
    override func resetChoiceButtonConstraint() {
        oButtonWidthConstraint.constant = 108
        xButtonWidthConstraint.constant = 108
    }
}
