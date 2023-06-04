//
//  PosePracticeCountDownView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/05/24.
//

import UIKit

final class PosePracticeCountDownView: UIView {

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .mainRed
        label.text = "pe_count_des_txt".localized()
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 98)
        label.textColor = .mainRed
        label.shadowColor = UIColor(rgb: 0xB50000)
        label.textAlignment = .center
        label.text = "3"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstriants()
        self.alpha = 0.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstriants() {
        let make = Constraints.shared
        
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = make.space8
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 150),
        ])
        
        [
            descriptionLabel,
            timeLabel
        ].forEach({
            stackView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            descriptionLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 42),
        ])
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: make.space8),
            timeLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func changeTimerValue(to value: Int) {
        timeLabel.text = "\(3 - value)"
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        })
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        })
    }
}
