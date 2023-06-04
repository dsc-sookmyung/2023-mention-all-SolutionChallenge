//
//  DispatchDescriptionView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/30.
//

import UIKit

enum DispatchDescriptionType: String {
    case startTime = "Start Time"
    case distance = "Distance"
}

class DispatchDescriptionView: UIView {

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textAlignment = .center
        label.textColor = .mainRed
        label.text = "---"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpConstraints() {
        let make = Constraints.shared
        
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
        ])
        
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = make.space4
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        titleLabel.sizeToFit()
        
        [
            stackView,
            descriptionLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 25)
        ])
        stackView.sizeToFit()
        titleLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: make.space4),
            descriptionLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 140),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func setUpComponent(imageName: String, type: DispatchDescriptionType) {
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        titleLabel.text =  type.rawValue
    }
    
    func setUpDescription(text: String) {
        descriptionLabel.text = text
    }
}
