//
//  EducationCollectionViewCell.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit

enum CourseStatus {
    case completed
    case now
    case locked
    
    var cellColor: UIColor {
        switch self {
        case .completed:
            return UIColor(rgb: 0xF4EFEA)
        case .now:
            return .mainRed
        case .locked:
            return UIColor(rgb: 0xDDDDDD)
        }
    }
    
    var defaultMainTextColor: UIColor {
        switch self {
        case .completed:
            return UIColor(rgb: 0x333333)
        case .now:
            return UIColor(rgb: 0xFFFFFF)
        case .locked:
            return UIColor(rgb: 0x828282)
        }
    }
    
    var defaultSubTextColor: UIColor {
        switch self {
        case .completed:
            return UIColor(rgb: 0x525252)
        case .now:
            return UIColor(rgb: 0xFFFFFF)
        case .locked:
            return UIColor(rgb: 0x999999)
        }
    }
    
    var timeNoticeLabelColor: UIColor {
        switch self {
        case .completed:
            return UIColor(rgb: 0x828282)
        case .now:
            return UIColor(rgb: 0xFBDDDE)
        case .locked:
            return  UIColor(rgb: 0xAAAAAA)
        }
    }
    
    var completeNoticeLabelColor: UIColor {
        switch self {
        case .completed:
            return .mainRed
        case .now:
            return UIColor(rgb: 0x525252)
        case .locked:
            return UIColor(rgb: 0xAAAAAA)
        }
    }
    
    var completeNoticeLabelText: String {
        switch self {
        case .completed:
            return "completed".localized()
            
        case .now:
            return "completed_not".localized()
        case .locked:
            return "open_not".localized()
        }
    }

    var isCheckIconVisible: Bool {
        switch self {
        case .completed:
            return true
        case .now, .locked:
            return false
        }
    }
    
    var isCourseNumberVisible: Bool {
        switch self {
        case .completed:
            return false
        case .now, .locked:
            return true
        }
    }
    
    var courseNumberLabelColor: UIColor {
        switch self {
        case .completed, .now:
            return .white
        case .locked:
            return UIColor(rgb: 0x828282)
        }
    }
    
    var courseViewColor: UIColor {
        switch self {
        case .completed, .now:
            return .mainRed
        case .locked:
            return UIColor(rgb: 0xF4EFEA)
        }
    }
}

final class EducationCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EducationCollectionViewCell"
    
    private lazy var educationNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 18)
        label.textAlignment = .left
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "check")
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var timeNoticeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 12)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 12)
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
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
            checkImageView,
            timeNoticeLabel,
            descriptionLabel,
            statusLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            educationNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: make.space16),
            educationNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: make.space20),
            educationNameLabel.heightAnchor.constraint(equalToConstant: 26),
        ])
        educationNameLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            checkImageView.leadingAnchor.constraint(equalTo: educationNameLabel.trailingAnchor, constant: make.space8),
            checkImageView.centerYAnchor.constraint(equalTo: educationNameLabel.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 16),
            checkImageView.heightAnchor.constraint(equalToConstant: 16),
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: educationNameLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: educationNameLabel.leadingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            statusLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -make.space16),
            statusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -make.space16),
            statusLabel.widthAnchor.constraint(equalToConstant: 110),
            statusLabel.heightAnchor.constraint(equalToConstant: 24)
            
        ])
        
        NSLayoutConstraint.activate([
            timeNoticeLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            timeNoticeLabel.leadingAnchor.constraint(equalTo: educationNameLabel.leadingAnchor),
            timeNoticeLabel.widthAnchor.constraint(equalToConstant: 160),
            timeNoticeLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
    }
    
    private func setUpStyle() {
        self.layer.cornerRadius = 16
    }
    
    func setUpComponent(timeValue: Int, status: CourseStatus) {
        print("STATUS?", status)
        self.layer.backgroundColor = status.cellColor.cgColor
        educationNameLabel.textColor = status.defaultMainTextColor
        descriptionLabel.textColor = status.defaultSubTextColor
        checkImageView.isHidden = !status.isCheckIconVisible
        timeNoticeLabel.textColor = status.timeNoticeLabelColor
        timeNoticeLabel.text = String(format: "taken_%dtime_des_txt".localized(), timeValue)
        statusLabel.textColor = status.completeNoticeLabelColor
        statusLabel.text = status.completeNoticeLabelText
    }

    func setUpLabelText(name: String, description: String) {
        educationNameLabel.text = name
        descriptionLabel.text = description
    }
}
