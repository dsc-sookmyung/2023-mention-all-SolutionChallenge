//
//  MypageStatusView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/31.
//

import UIKit

final class MypageStatusView: UIView {

    private lazy var angelStatusImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 18)
        label.textColor = .mainBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var angelStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 20)
        label.textColor = .mainRed
        label.textAlignment = .center
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 18)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Expiration period"
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .mainLightRed.withAlphaComponent(0.05)
        view.progressTintColor = .mainRed
        view.layer.borderColor = UIColor.mainRed.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 6
        view.layer.sublayers![1].cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var expirationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let viewModel: EducationViewModel
    
    init(viewModel: EducationViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setUpConstraints()
        setUpStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        [
            angelStatusImageView,
            nicknameLabel,
            angelStatusLabel,
            periodLabel,
            progressView,
            expirationLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            angelStatusImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 28),
            angelStatusImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 35),
            angelStatusImageView.widthAnchor.constraint(equalToConstant: 60),
            angelStatusImageView.heightAnchor.constraint(equalToConstant: 72)
        ])
        
        NSLayoutConstraint.activate([
            nicknameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 22),
            nicknameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            nicknameLabel.widthAnchor.constraint(equalToConstant: 230),
            nicknameLabel.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        NSLayoutConstraint.activate([
            angelStatusLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            angelStatusLabel.centerXAnchor.constraint(equalTo: nicknameLabel.centerXAnchor),
            angelStatusLabel.widthAnchor.constraint(equalToConstant: 230),
            angelStatusLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        NSLayoutConstraint.activate([
            periodLabel.topAnchor.constraint(equalTo: angelStatusImageView.bottomAnchor, constant: 24),
            periodLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14),
            periodLabel.widthAnchor.constraint(equalToConstant: 175),
            periodLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: periodLabel.bottomAnchor, constant: 8),
            progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 330),
            progressView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        NSLayoutConstraint.activate([
            expirationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            expirationLabel.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
            expirationLabel.widthAnchor.constraint(equalToConstant: 200),
            expirationLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setUpStyle() {
        self.layer.cornerRadius = 16
        self.layer.borderColor = UIColor.mainRed.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = .mainWhite
    }
    
    func setUpStatusComponent(certificate: CertificateStatus) {
        let imgName = certificate.status.certificationImageName(true)
        
        var statusText: String = ""
        var leftDay: Int = 0
        if let day = certificate.leftDay {
            statusText = "\(certificate.status.certificationStatus()) (D-\(day))"
            leftDay = day
        } else {
            statusText = "\(certificate.status.certificationStatus())"
        }
        
        angelStatusImageView.image = UIImage(named: imgName)
        angelStatusLabel.text = statusText
        
        [periodLabel, progressView, expirationLabel].forEach({$0.isHidden = (certificate.status != .acquired) })
        
        progressView.progress = Float(leftDay)/90
        expirationLabel.text = leftDay.numberAsExpirationDate()
    }
    
    func setUpGreetingLabel(nickname: String) {
        nicknameLabel.text = "Hi \(nickname)\nYour Certification Status is"
    }
}
