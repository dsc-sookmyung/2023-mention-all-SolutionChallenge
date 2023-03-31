//
//  EducationCollectionViewCell.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit

final class EducationCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EducationCollectionViewCell"
    
    private lazy var educationNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 16)
        label.textColor = .mainBlack
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 12)
        label.textColor = .mainBlack
        return label
    }()
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 16)
        label.textColor = .mainRed
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
            educationNameLabel,
            descriptionLabel,
            statusLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            educationNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: make.space10),
            educationNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space20),
            educationNameLabel.widthAnchor.constraint(equalToConstant: 160),
            educationNameLabel.heightAnchor.constraint(equalToConstant: 18),
            
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: educationNameLabel.bottomAnchor, constant: make.space2),
            descriptionLabel.leadingAnchor.constraint(equalTo: educationNameLabel.leadingAnchor),
            educationNameLabel.widthAnchor.constraint(equalToConstant: 160),
            educationNameLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        NSLayoutConstraint.activate([
            statusLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -make.space18),
            statusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space14)
        ])
        
    }
    
    private func setUpStyle() {
        self.layer.cornerRadius = 20
    }
    
    func setUpEducationNameLabel(as str: String) {
        educationNameLabel.text = str
    }
    
    func setUpDescriptionLabel(as str: String) {
        descriptionLabel.text = str
    }
    
    func setUpStatus(isCompleted: Bool) {
        statusLabel.text = isCompleted == true ? "Completed" : "Not Completed"
        statusLabel.textColor = isCompleted == true ? .mainRed : .mainDarkGray
        self.backgroundColor = isCompleted  == true ? .mainLightRed : .mainLightGray
    }

}
