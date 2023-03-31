//
//  EvaluationResultView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit

final class EvaluationResultView: UIView {

    private let evaluationTargetImageView = UIImageView()
    private let titleLabel = UILabel()
    private let resultLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpConstraints()
        setUpStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        
        [
            evaluationTargetImageView,
            titleLabel,
            resultLabel,
            descriptionLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            evaluationTargetImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: make.space12),
            evaluationTargetImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space16),
            evaluationTargetImageView.widthAnchor.constraint(equalToConstant: 28),
            evaluationTargetImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: evaluationTargetImageView.trailingAnchor, constant: make.space4),
            titleLabel.centerYAnchor.constraint(equalTo: evaluationTargetImageView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 180),
            titleLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: make.space24),
            resultLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            resultLabel.widthAnchor.constraint(equalToConstant: 145),
            resultLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: resultLabel.leadingAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 180),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setUpStyle() {
        self.layer.cornerRadius = 16
        self.layer.borderColor = UIColor.mainRed.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = .mainLightRed.withAlphaComponent(0.05)
        
        [
            titleLabel, resultLabel, descriptionLabel
        ].forEach({
            $0.textColor = .mainBlack
            $0.textAlignment = .left
        })
        titleLabel.font = UIFont(weight: .bold, size: 20)
        resultLabel.font = UIFont(weight: .bold, size: 14)
        descriptionLabel.font = UIFont(weight: .regular, size: 14)
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.5
        descriptionLabel.numberOfLines = 3
    }
    
    func setImage(imgName systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular, scale: .medium)
        evaluationTargetImageView.image = UIImage(systemName: systemName, withConfiguration: config)
        
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setResultLabelText(as text: String) {
        resultLabel.text = text
    }
    
    func setDescriptionLabelText(as text: String) {
        descriptionLabel.text = text
    }
}
