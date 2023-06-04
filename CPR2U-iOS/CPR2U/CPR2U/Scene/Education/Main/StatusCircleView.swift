//
//  StatusCircleView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/05/30.
//

import UIKit

final class StatusCircleView: UIView {

    private let checkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .white
        return view
    }()
    private lazy var courseNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 14)
        label.textAlignment = .center
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
        [
            checkImageView,
            courseNumberLabel
        ].forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            checkImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            courseNumberLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            courseNumberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            courseNumberLabel.widthAnchor.constraint(equalToConstant: 24),
            courseNumberLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setUpStyle() {
        self.layer.cornerRadius = 20
    }
    
    func setUpComponent(courseNumber: Int, status:CourseStatus) {
        self.backgroundColor = status.courseViewColor
        checkImageView.isHidden = !status.isCheckIconVisible
        courseNumberLabel.isHidden = !status.isCourseNumberVisible
        courseNumberLabel.textColor = status.courseNumberLabelColor
        courseNumberLabel.text = "\(courseNumber)"
    }
                  
}
