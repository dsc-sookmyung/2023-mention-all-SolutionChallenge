//
//  CurrentLocationNoticeView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import UIKit

class CurrentLocationNoticeView: UIView {

    private let pinImageView: UIImageView = {
        let view = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .light, scale: .medium)
        guard let img = UIImage(systemName: "mappin.circle", withConfiguration: config)?.withTintColor(.mainRed).withRenderingMode(.alwaysOriginal) else { return UIImageView() }
        view.image = img
        return view
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 16)
        label.textAlignment = .left
        label.textColor = .black
        label.minimumScaleFactor = 0.5
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
            pinImageView,
            locationLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            pinImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space8),
            pinImageView.widthAnchor.constraint(equalToConstant: 28),
            pinImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        NSLayoutConstraint.activate([
            locationLabel.leadingAnchor.constraint(equalTo: pinImageView.trailingAnchor, constant: make.space8),
            locationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space8),
            locationLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func setUpStyle() {
        backgroundColor = .white
        self.layer.borderColor = UIColor.mainRed.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 20
    }
    
    func setUpLocationLabelText(as str: String) {
        locationLabel.text = str
    }

}
