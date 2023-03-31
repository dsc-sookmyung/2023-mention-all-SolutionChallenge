//
//  CustomNoticeView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import UIKit

protocol CustomNoticeViewDelegate: AnyObject {
    func dismissQuizViewController()
}

enum NoticeUsage {
    case pf
    case certificate
}

class CustomNoticeView: UIView {
    
    weak var delegate: CustomNoticeViewDelegate?
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(rgb: 0x7B7B7B).withAlphaComponent(0.45)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    } ()
    
    private let noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xFCFCFC)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 18)
        label.textAlignment = .center
        label.textColor = .mainBlack
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .center
        label.textColor = .mainBlack
        return label
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 22
        button.backgroundColor = .mainRed
        button.titleLabel?.font = UIFont(weight: .bold, size: 17)
        button.setTitleColor(.mainWhite, for: .normal)
        button.setTitle("CONFIRM", for: .normal)
        return button
    }()
    private let appearAnimDuration: CGFloat = 0.4
    
    private var noticeType = NoticeUsage.pf

    init(noticeAs: NoticeUsage) {
        super.init(frame: CGRect.zero)
        
        setUpConstraints()
        setUpStyle()
        setUpComponent()
        noticeType = noticeAs
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        
        self.addSubview(noticeView)
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            noticeView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            noticeView.widthAnchor.constraint(equalToConstant: 313),
            noticeView.heightAnchor.constraint(equalToConstant: 308)
        ])
        
        [
            thumbnailImageView,
            titleLabel,
            subTitleLabel,
            confirmButton
        ].forEach({
            noticeView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: noticeView.topAnchor, constant: 40),
            thumbnailImageView.leadingAnchor.constraint(equalTo: noticeView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: noticeView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 95)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: make.space24),
            titleLabel.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: noticeView.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: make.space2),
            subTitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            subTitleLabel.widthAnchor.constraint(equalToConstant: 264),
            subTitleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: noticeView.bottomAnchor, constant: -26),
            confirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 206),
            confirmButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    private func setUpStyle() {
        self.alpha = 0.0
        self.backgroundColor = UIColor(rgb: 0x7B7B7B).withAlphaComponent(0.45)
    }
    
    private func setUpComponent() {
        confirmButton.addTarget(self, action: #selector(didConfirmButtonTapped), for: .touchUpInside)
    }
    
    func setCertificateNotice() {
        setTitle(title: "Congratulation!")
        guard let image = UIImage(named: "certificate_big.png") else { return }
        setImage(uiImage: image)
        setSubTitle(subTitle: "You have got CPR Angel Certificate!")
    }
    
    func setPFResultNotice(isPass: Bool, quizResultString: String = ""){
        if isPass {
            guard let image = UIImage(named: "success_heart.png") else { return }
            setImage(uiImage: image)
            setTitle(title: "Congratulation!")
            setSubTitle(subTitle: "You are perfect!")
        } else {
            guard let image = UIImage(named: "fail_heart.png") else { return }
            setImage(uiImage: image)
            setTitle(title: "Failed \(quizResultString)")
            setSubTitle(subTitle: "Try Again")
        }
        
    }
    private func setImage(uiImage: UIImage) {
        thumbnailImageView.image = uiImage
    }
    
    private func setTitle(title: String) {
        titleLabel.text = title
    }
    
    private func setSubTitle(subTitle: String) {
        subTitleLabel.text = subTitle
    }
    
    @objc func didConfirmButtonTapped() {
        if noticeType == .pf {
            delegate?.dismissQuizViewController()
        } else {
            noticeDisappear()
        }
    }
    
    func noticeAppear() {
        self.superview?.isUserInteractionEnabled = false
        UIView.animate(withDuration: appearAnimDuration, animations: {
            self.alpha = 1.0
        }, completion: { _ in
                self.superview?.isUserInteractionEnabled = true
        })
    }
                       
    func noticeDisappear() {
        UIView.animate(withDuration: appearAnimDuration/2, delay: 0, animations: {
            self.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.superview?.isUserInteractionEnabled = true
            self?.removeFromSuperview()
        })
    }
}
