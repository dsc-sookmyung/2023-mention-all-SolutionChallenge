//
//  EmergencyNoticeView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import UIKit

final class EmergencyDescriptionView: UIView {
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 20)
        label.textAlignment = .left
        label.textColor = .mainBlack
        label.text = "Call 911"
        return label
    }()
    
    private let descriptonLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 4
        label.textColor = .mainBlack
        label.text = "Calling 911 is the first priority. Ask the people around you to report or perform CPR after reporting. If the report is false, you will be restricted from using the app."
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
            mainLabel,
            descriptonLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: make.space24),
            mainLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space24),
            mainLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space24),
            mainLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        NSLayoutConstraint.activate([
            descriptonLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -34),
            descriptonLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space24),
            descriptonLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space24),
            descriptonLabel.heightAnchor.constraint(equalToConstant: 96)
        ])
    }
    
    private func setUpStyle() {
        backgroundColor = .white
        self.layer.cornerRadius = 8
    }
}
