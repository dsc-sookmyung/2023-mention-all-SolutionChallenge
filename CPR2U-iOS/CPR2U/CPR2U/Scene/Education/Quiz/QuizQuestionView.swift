//
//  QuizQuestionView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit

final class QuizQuestionView: UIView {

    private lazy var questionNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 28)
        label.textColor = .mainRed
        return label
    }()
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 20)
        label.textColor = .mainBlack
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private let questionLeftDecoLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainLightRed
        return view
    }()
    
    init(questionNumber: Int, question: String) {
        super.init(frame: CGRect.zero)
        
        setUpConstraints()
        setUpText(questionNumber: questionNumber, question: question)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        [
            questionNumberLabel,
            questionLabel,
            questionLeftDecoLine
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            questionNumberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            questionNumberLabel.topAnchor.constraint(equalTo: self.topAnchor),
            questionNumberLabel.widthAnchor.constraint(equalToConstant: 70),
            questionNumberLabel.heightAnchor.constraint(equalToConstant: 38),
        ])
        
        NSLayoutConstraint.activate([
            questionLeftDecoLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space24),
            questionLeftDecoLine.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: make.space24),
            questionLeftDecoLine.widthAnchor.constraint(equalToConstant: 3),
            questionLeftDecoLine.heightAnchor.constraint(equalToConstant: 75),
        ])
        
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: questionLeftDecoLine.trailingAnchor, constant: make.space8),
            questionLabel.centerYAnchor.constraint(equalTo: questionLeftDecoLine.centerYAnchor),
            questionLabel.widthAnchor.constraint(equalToConstant: 295),
            questionLabel.heightAnchor.constraint(equalToConstant: 95),
        ])
    }
    
    func setUpText(questionNumber: Int, question: String) {
        let number = questionNumber > 10 ? "0\(questionNumber)" : String(questionNumber)
        questionNumberLabel.text = "Q. \(number)"
        questionLabel.text = question
    }
}
