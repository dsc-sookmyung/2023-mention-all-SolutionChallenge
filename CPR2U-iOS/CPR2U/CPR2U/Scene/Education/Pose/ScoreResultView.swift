//
//  AccuracyResultView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit

final class ScoreResultView: UIView {
    
    private let scoreImageView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textColor = .mainBlack
        label.textAlignment = .center
        label.text = "score".localized()
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 80)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .mainBlack
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textAlignment = .center
        label.textColor = .mainBlack
        return label
    }()
    
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
            scoreImageView,
            titleLabel,
            scoreLabel,
            descriptionLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            scoreImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: make.space14),
            scoreImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space14),
            scoreImageView.widthAnchor.constraint(equalToConstant: 28),
            scoreImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: scoreImageView.trailingAnchor, constant: make.space8),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space8),
            titleLabel.centerYAnchor.constraint(equalTo: scoreImageView.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -make.space16),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            scoreLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -40),
            scoreLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 200),
            scoreLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }
    
    private func setUpStyle() {
        self.layer.cornerRadius = 16
        self.layer.borderColor = UIColor.mainRed.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = .mainLightRed.withAlphaComponent(0.05)
        
        
    }
    
    func setUpScore(score: Int) {
        let scoreStr = "\(score)/100"
        scoreLabel.text = scoreStr
        scoreLabel.attributedText = arrangeScoreText(text: scoreLabel.text ?? "")
        
        if score >= 80 {
            descriptionLabel.text = "pass".localized()
        } else {
            descriptionLabel.text = "fail".localized()
        }
        print(scoreLabel.text)
    }
    
    private func arrangeScoreText(text: String) -> NSAttributedString {
        var range: Int = 0
        let attributedString = NSMutableAttributedString(string: text)
        if let rangeS = text.range(of: "/") {
            range = text.distance(from: text.startIndex, to: rangeS.lowerBound)
        }
        
        let realScoreAttributes: [NSAttributedString.Key: Any] = [
            .font : UIFont(weight: .bold, size: 72) ?? UIFont(),
            .foregroundColor : UIColor.mainWhite
        ]
        
        let defaultScoreAttributes: [NSAttributedString.Key: Any] = [
            .font : UIFont(weight: .bold, size: 32) ?? UIFont(),
            .foregroundColor : UIColor.mainLightRed
        ]
        
        attributedString.addAttributes(realScoreAttributes, range: NSRange(location: 0, length: range))
        attributedString.addAttributes(defaultScoreAttributes, range: NSRange(location: range, length: attributedString.length - range))
        
        return attributedString
    }
    
}
