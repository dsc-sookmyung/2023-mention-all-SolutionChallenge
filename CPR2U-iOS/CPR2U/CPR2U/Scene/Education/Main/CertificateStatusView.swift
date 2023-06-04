//
//  CertificateStatusView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/09.
//

import Foundation
import UIKit

final class CertificateStatusView: UIView {

    private let status: AngelStatus = .unacquired
    private let certificateImage = UIImageView()
    private lazy var  greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        return label
    }()
    
    private lazy var certificateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
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
        
        let labelStackView   = UIStackView()
        labelStackView.axis  = NSLayoutConstraint.Axis.vertical
        labelStackView.distribution  = UIStackView.Distribution.equalSpacing
        labelStackView.alignment = UIStackView.Alignment.center
        
        [
            certificateImage,
            labelStackView
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })

        NSLayoutConstraint.activate([
            certificateImage.leadingAnchor.constraint(equalTo: super.leadingAnchor, constant: make.space24),
            certificateImage.centerYAnchor.constraint(equalTo: super.centerYAnchor),
            certificateImage.widthAnchor.constraint(equalToConstant: 28),
            certificateImage.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: certificateImage.trailingAnchor, constant: make.space16),
            labelStackView.centerYAnchor.constraint(equalTo: certificateImage.centerYAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space16),
            labelStackView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        
        [
            greetingLabel,
            certificateLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: labelStackView.topAnchor),
            greetingLabel.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            greetingLabel.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
            greetingLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        NSLayoutConstraint.activate([
            certificateLabel.bottomAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: make.space2),
            certificateLabel.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            certificateLabel.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
            certificateLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setUpStyle() {
        self.layer.cornerRadius = 16
        self.backgroundColor = .mainWhite
    }
    
    func setUpStatus(as status: AngelStatus, leftDay: Int?) {
        
        let imgName = status.certificationImageName()
        certificateImage.image = UIImage(named: imgName)
        
        var statusString: String
        if let leftDayString = leftDay {
            statusString = "\(status.getStatus()) (D-\(leftDayString))"
        } else {
            statusString = status.getStatus()
        }
        let certificateStatusString = "cert_status_ann_txt".localized()
        let customFont = UIFont(weight: .bold, size: 14)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: customFont,
            .foregroundColor: UIColor.mainRed
        ]
        let resultString = NSMutableAttributedString(string: certificateStatusString)
        let attributedString = NSMutableAttributedString(string: statusString, attributes: attributes)
        resultString.append(attributedString)
        
        certificateLabel.attributedText = resultString
    }
    
    func setUpGreetingLabel(nickname: String) {
        let localizedStr = String(format: "%@_greeting_txt".localized(), nickname)
        greetingLabel.text = localizedStr
    }
}
