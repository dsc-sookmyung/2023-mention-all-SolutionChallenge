//
//  EvaluationResultView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit

final class EvaluationResultView: UIView {
    private let evaluationTargetImageView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 16)
        label.textColor = .mainWhite
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionImageView = UIImageView()
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 14)
        label.textColor = .mainWhite
        label.textAlignment = .center
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainWhite
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        
        let titleStackView = UIStackView(arrangedSubviews: [
            evaluationTargetImageView,
            titleLabel
        ])
        titleStackView.axis = NSLayoutConstraint.Axis.horizontal
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .center
        titleStackView.spacing   = make.space8
        
        let stackView = UIStackView(arrangedSubviews: [
            titleStackView,
            descriptionImageView,
            resultLabel,
            descriptionLabel
        ])
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = make.space8
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        [
            titleStackView,
            descriptionImageView,
            resultLabel,
            descriptionLabel
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            titleStackView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        [
            evaluationTargetImageView,
            titleLabel
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        
        NSLayoutConstraint.activate([
            evaluationTargetImageView.widthAnchor.constraint(equalToConstant: 28),
            evaluationTargetImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        NSLayoutConstraint.activate([
            descriptionImageView.widthAnchor.constraint(equalToConstant: 48),
            descriptionImageView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            resultLabel.widthAnchor.constraint(equalToConstant: 200),
            resultLabel.heightAnchor.constraint(equalToConstant: 21)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.widthAnchor.constraint(equalToConstant: 180),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setImage(imgName systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular, scale: .medium)
        evaluationTargetImageView.image = UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(.mainWhite, renderingMode: .alwaysOriginal)
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setResultImageView(isSuccess: Bool) {
        let image = isSuccess ? UIImage(named: "check_badge.png") : UIImage(named: "x_mark.png")
        descriptionImageView.image = image
    }
    
    func setResultLabelText(as text: String) {
        resultLabel.text = text
    }
    
    func setDescriptionLabelText(as text: String) {
        descriptionLabel.text = text
    }
}
