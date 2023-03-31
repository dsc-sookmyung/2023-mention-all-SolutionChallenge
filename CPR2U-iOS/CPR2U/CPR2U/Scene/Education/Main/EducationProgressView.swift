//
//  EducationProgressView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/09.
//

import UIKit

final class EducationProgressView: UIView {

    private let annotationLabel: UILabel = {
        let label = UILabel()
        let color = UIColor(rgb: 0x767676)
        label.font = UIFont(weight: .regular, size: 11)
        label.textColor = color
        label.text = "CPR Angel Certification Progress"
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        let color = UIColor(rgb: 0x767676)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .light, scale: .medium)
        guard let img = UIImage(systemName: "info.circle", withConfiguration: config)?.withTintColor(color).withRenderingMode(.alwaysOriginal) else { return UIButton() }
        button.setImage(img, for: .normal)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .mainLightRed.withAlphaComponent(0.05)
        view.progressTintColor = .mainRed
        view.layer.borderColor = UIColor.mainRed.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.sublayers![1].cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        
        [
            annotationLabel,
            infoButton,
            progressView
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            annotationLabel.topAnchor.constraint(equalTo: self.topAnchor),
            annotationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space6),
            annotationLabel.widthAnchor.constraint(equalToConstant: 168),
            annotationLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        NSLayoutConstraint.activate([
            infoButton.leadingAnchor.constraint(equalTo: annotationLabel.trailingAnchor, constant: make.space4),
            infoButton.centerYAnchor.constraint(equalTo: annotationLabel.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 10),
            infoButton.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: annotationLabel.bottomAnchor, constant: make.space2),
            progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space6),
            progressView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func setUpProgress(as value: Float) {
        progressView.progress = value
    }
}
