//
//  CustomNoticeView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/10.
//

import Combine
import UIKit

protocol CustomNoticeViewDelegate: AnyObject {
    func dismissQuizViewController()
}

enum NoticeUsage: Equatable {
    case lecturePass
    case quizFail(score: String)
    case quizPass
    case certificate
    case dispatchComplete
    
    var imageName: String {
        switch self {
        case .quizFail:
            return "heart_fail"
        case .lecturePass, .quizPass, .certificate, .dispatchComplete:
            return "heart_success"
        }
    }
    
    var titleText: String {
        switch self {
        case .lecturePass:
            return "lecture_pass_title_txt".localized()
        case .quizFail(let score):
            return String(format: "quiz_fail_title_txt_%@".localized(), score)
        case .quizPass:
            return "quiz_pass_title_txt".localized()
        case .certificate:
            return "certificate_title_txt".localized()
        case .dispatchComplete:
            return "dispatchComplete_title_txt".localized()
        }
    }
    
    var descriptionText: String {
        switch self {
        case .lecturePass:
            return "lecture_pass_des_txt".localized()
        case .quizFail:
            return "quiz_fail_des_txt".localized()
        case .quizPass:
            return "quiz_pass_des_txt".localized()
        case .certificate:
            return "certificate_des_txt".localized()
        case .dispatchComplete:
            return "dispatchComplete_des_txt".localized()
        }
    }
    
    var confirmButtonTopAnchorMargin: CGFloat {
        switch self {
        case .lecturePass, .quizFail, .quizPass, .certificate:
            return 24
        case .dispatchComplete:
            return 0
        }
    }
    
    var isNeedDelegate: Bool {
        switch self {
        case .quizFail, .quizPass:
            return true
        case .lecturePass, .certificate, .dispatchComplete:
            return false
        }
    }
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
    
    private lazy var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = UIColor(rgb: 0x525252)
        
        return label
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 24
        button.backgroundColor = .mainRed
        button.titleLabel?.font = UIFont(weight: .bold, size: 14)
        button.setTitleColor(.mainWhite, for: .normal)
        button.setTitle("got_it".localized(), for: .normal)
        return button
    }()
    
    private lazy var reportLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        label.textAlignment = .center
        label.text = "report_title_txt".localized()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let appearAnimDuration: CGFloat = 0.4
    
    private var noticeType: NoticeUsage?

    private var dispatchId: Int?
    private var cancellables = Set<AnyCancellable>()
    
    init(noticeAs: NoticeUsage) {
        super.init(frame: CGRect.zero)
        self.dispatchId = nil
        noticeType = noticeAs
        setUpComponent(noticeUsage: noticeAs)
        setUpConstraints()
        setUpStyle()
        setUpComponent()
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
            noticeView.widthAnchor.constraint(equalToConstant: 314),
            noticeView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        [
            thumbnailImageView,
            titleLabel,
            descriptionLabel,
            confirmButton
        ].forEach({
            noticeView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: noticeView.topAnchor, constant: 36),
            thumbnailImageView.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 54.78),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: make.space16),
            titleLabel.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: noticeView.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: make.space12),
            descriptionLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 264),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        guard let noticeType = noticeType else { return }
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: noticeType.confirmButtonTopAnchorMargin),
            confirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 230),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        if noticeType == .dispatchComplete {
            makeReportLabel()
        }
    }
    
    private func setUpStyle() {
        self.alpha = 0.0
        self.backgroundColor = UIColor(rgb: 0x7B7B7B).withAlphaComponent(0.45)
    }
    
    private func setUpComponent() {
        confirmButton.addTarget(self, action: #selector(didConfirmButtonTapped), for: .touchUpInside)
    }
    
    @objc func didConfirmButtonTapped() {
        guard let noticeType = noticeType else { return }
        if noticeType.isNeedDelegate == true {
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
    
    func noticeHide() {
        UIView.animate(withDuration: appearAnimDuration/2, delay: 0, animations: {
            self.alpha = 0.0
        })
    }
    
    func makeReportLabel() {
        noticeView.addSubview(reportLabel)
        reportLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reportLabel.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: Constraints.shared.space8),
            reportLabel.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            reportLabel.widthAnchor.constraint(equalToConstant: 264),
            reportLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    // https://stackoverflow.com/questions/34649173/how-can-i-call-presentviewcontroller-in-uiview-class
    func getCurrentViewController() -> UIViewController? {
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }
    
    func setUpComponent(noticeUsage: NoticeUsage) {
        thumbnailImageView.image = UIImage(named: noticeUsage.imageName)
        titleLabel.text = noticeUsage.titleText
        descriptionLabel.text = noticeUsage.descriptionText
    }
    
    func setUpQuizResult(isPassed: Bool, score: String) {
        if isPassed {
            setUpComponent(noticeUsage: .quizPass)
        } else {
            setUpComponent(noticeUsage: .quizFail(score: score))
        }
    }
    
    func setUpDispatchComponent(dispatchId: Int) {
        self.dispatchId = dispatchId
    }
    
    func setUpAction(callVC: CallMainViewController, viewModel: CallViewModel) {
        let tapGesture = UITapGestureRecognizer()
        reportLabel.addGestureRecognizer(tapGesture)
        tapGesture.tapPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            guard let dispatchId = self.dispatchId else { return }
            let vc = ReportViewController(dispatchId: dispatchId, viewModel: viewModel)
            vc.delegate = callVC.self
            vc.modalPresentationStyle = .fullScreen
            guard let currentVC = getCurrentViewController() else { return }
            currentVC.present(vc, animated: true)
        }.store(in: &cancellables)
    }
}
