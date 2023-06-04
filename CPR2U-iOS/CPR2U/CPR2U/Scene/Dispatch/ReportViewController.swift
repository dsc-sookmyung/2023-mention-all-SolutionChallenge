//
//  ReportViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/31.
//

import Combine
import CombineCocoa
import UIKit

protocol ReportViewControllerDelegate: AnyObject {
    func noticeDisappear()
}
final class ReportViewController: UIViewController {
    
    weak var delegate: ReportViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .mainBlack
        label.text = "report_ins_txt".localized()
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .left
        label.textColor = .mainBlack
        label.text = "report_des_txt".localized()
        return label
    }()
    
    private let placeHolder = "report_phdr".localized()
    private let reportTextView: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
        view.textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        view.font = .systemFont(ofSize: 18)
        view.text = "Content*"
        view.textColor = .lightGray
        return view
    }()
    
    private var submitButtonBottomConstraint = NSLayoutConstraint()
    private let submitButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(weight: .bold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainRed
        button.layer.cornerRadius = 27.5
        button.setTitle("submit".localized(), for: .normal)
        return button
    }()
    
    private let dispatchId: Int
    private let viewModel: CallViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(dispatchId: Int, viewModel: CallViewModel) {
        self.dispatchId = dispatchId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConstraints()
        setUpStyle()
        setUpDelegate()
        setUpAction()
        setUpKeyboard()
    }

    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let make = Constraints.shared
        [
            titleLabel,
            descriptionLabel,
            reportTextView,
            submitButton
            
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        })
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: make.space16),
            titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 340),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: make.space16),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 340),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            reportTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: make.space18),
            reportTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: make.space16),
            reportTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -make.space16),
            reportTextView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        submitButtonBottomConstraint = submitButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16)
        NSLayoutConstraint.activate([
            submitButtonBottomConstraint,
            submitButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space8),
            submitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space8),
            submitButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func setUpDelegate() {
        reportTextView.delegate = self
    }
    
    private func setUpAction() {
        submitButton.tapPublisher.sink { [self] in
            Task {
                let reportInfo = ReportInfo(content: reportTextView.text, dispatch_id: dispatchId)
                let isSucceed = try await viewModel.userReport(reportInfo: reportInfo)
                if isSucceed {
                    dismiss(animated: true)
                    delegate?.noticeDisappear()
                }
                
            }
        }.store(in: &cancellables)
    }
    
    private func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height

            submitButtonBottomConstraint.constant = -keyboardHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        submitButtonBottomConstraint.constant = -16
        view.layoutIfNeeded()
    }
}

extension ReportViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeHolder
            textView.textColor = .lightGray
        }
    }
}
