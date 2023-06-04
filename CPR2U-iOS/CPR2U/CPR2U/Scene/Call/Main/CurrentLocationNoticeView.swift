//
//  CurrentLocationNoticeView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/25.
//

import UIKit

enum LocationInfo {
    case originLocation
    case targetLocation
}

class CurrentLocationNoticeView: UIView {

    private let pinImageView: UIImageView = {
        let view = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .light, scale: .medium)
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
    
    init(locationInfo: LocationInfo) {
        super.init(frame: CGRect.zero)
        
        setUpConstraints(locationInfo: locationInfo)
        setUpStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints(locationInfo: LocationInfo) {
        let make = Constraints.shared
        
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = 0
        
        if locationInfo == .targetLocation {
            let descriptionLabel = UILabel()
            descriptionLabel.font = UIFont(weight: .regular, size: 12)
            descriptionLabel.textAlignment = .left
            descriptionLabel.textColor = UIColor(rgb: 0x939393)
            descriptionLabel.text = "patient_loc_txt".localized()
            
            stackView.addArrangedSubview(descriptionLabel)
            
            NSLayoutConstraint.activate([
                descriptionLabel.widthAnchor.constraint(equalToConstant: 180),
                descriptionLabel.heightAnchor.constraint(equalToConstant: 14)
            ])
        }
        
        stackView.addArrangedSubview(locationLabel)
        
        
        [
            pinImageView,
            stackView
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
            stackView.leadingAnchor.constraint(equalTo: pinImageView.trailingAnchor, constant: make.space10),
            stackView.centerYAnchor.constraint(equalTo: pinImageView.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            stackView.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        NSLayoutConstraint.activate([
            locationLabel.widthAnchor.constraint(equalToConstant: 300),
            locationLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setUpStyle() {
        backgroundColor = .white
        self.layer.borderColor = UIColor.mainRed.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 16
    }
    
    func setUpLocationLabelText(as str: String) {
        locationLabel.text = str
    }

}
