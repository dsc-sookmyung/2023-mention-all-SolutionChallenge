//
//  DispatchDescriptionView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/30.
//

import UIKit

enum DispatchDescriptionType: String {
    case duration = "Duration"
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
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 18)
        label.textAlignment = .center
        label.textColor = .black
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
        [
            imageView,
            titleLabel,
            descriptionLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 75),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 75),
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
