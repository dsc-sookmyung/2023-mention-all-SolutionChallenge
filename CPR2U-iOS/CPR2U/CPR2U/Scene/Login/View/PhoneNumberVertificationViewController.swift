//
//  PhoneNumberVerificationViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/02.
//

import Combine
import CombineCocoa
import UIKit

final class PhoneNumberVerificationViewController: UIViewController {
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textColor = .mainBlack
        label.text = "pn_ins_txt".localized()
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        label.text = "pn_des_txt".localized()
        return label
    }()
    
    private let phoneNumberView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(rgb:0xF2F2F2).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let phoneNumberNationView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.backgroundColor = UIColor(rgb:0xF2F2F2)
        return view
    }()
    
    private let phoneNumberNationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 15)
        label.textAlignment = .center
        label.textColor = .mainBlack
        label.text = "nation_code".localized()
        return label
    }()
    
    private let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .mainBlack
        textField.font = UIFont(weight: .regular, size: 16)
        textField.placeholder = "pn_phdr".localized()
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(weight: .bold, size: 16)
        button.setTitle("send".localized(), for: .normal)
        button.setTitleColor(.mainBlack, for: .normal)
        button.backgroundColor = .mainLightGray
        button.layer.cornerRadius = 27.5
        button.isEnabled = false
        return button
    }()
    
    private var sendButtonBottomConstraints = NSLayoutConstraint()
    
    private var viewModel: AuthViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AuthViewModel) {
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
        setUpKeyboard()
        bind(to: viewModel)
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        let safeArea = view.safeAreaLayoutGuide
        
        [
            instructionLabel,
            descriptionLabel,
            phoneNumberView,
            sendButton
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        [
            phoneNumberNationView,
            phoneNumberTextField
        ].forEach({
            phoneNumberView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: make.space16),
            instructionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            instructionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            instructionLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: make.space4),
            descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: make.space16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 28)
        ])

        NSLayoutConstraint.activate([
            phoneNumberView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: make.space8),
            phoneNumberView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            phoneNumberView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            phoneNumberView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            phoneNumberNationView.topAnchor.constraint(equalTo: phoneNumberView.topAnchor),
            phoneNumberNationView.leadingAnchor.constraint(equalTo: phoneNumberView.leadingAnchor),
            phoneNumberNationView.widthAnchor.constraint(equalToConstant: 72),
            phoneNumberNationView.heightAnchor.constraint(equalTo: phoneNumberView.heightAnchor)
        ])
        
        phoneNumberNationView.addSubview(phoneNumberNationLabel)
        phoneNumberNationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            phoneNumberNationLabel.topAnchor.constraint(equalTo: phoneNumberNationView.topAnchor),
            phoneNumberNationLabel.bottomAnchor.constraint(equalTo: phoneNumberNationView.bottomAnchor),
            phoneNumberNationLabel.leadingAnchor.constraint(equalTo: phoneNumberNationView.leadingAnchor),
            phoneNumberNationLabel.trailingAnchor.constraint(equalTo: phoneNumberNationView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            phoneNumberTextField.topAnchor.constraint(equalTo: phoneNumberView.topAnchor),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: phoneNumberNationView.trailingAnchor, constant: make.space16),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: phoneNumberView.trailingAnchor),
            phoneNumberTextField.heightAnchor.constraint(equalTo: phoneNumberView.heightAnchor)
        ])

        sendButtonBottomConstraints = sendButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16)
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            sendButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            sendButtonBottomConstraints,
            sendButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func setUpKeyboard() {
        phoneNumberTextField.becomeFirstResponder()
        phoneNumberTextField.keyboardType = .numberPad
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    private func bind(to viewModel: AuthViewModel) {
        let input = AuthViewModel.Input(
            verifier: phoneNumberTextField.textPublisher.eraseToAnyPublisher()
        )

        let output = viewModel.transform(loginPhase: LoginPhase.PhoneNumber, input: input)

        output
            .buttonIsValid?
            .sink(receiveValue: { [weak self] state in
                self?.sendButton.isEnabled = state
                self?.sendButton.setTitleColor(state ? .mainWhite : .mainBlack, for: .normal)
                self?.sendButton.backgroundColor = state ? .mainRed : .mainLightGray
            })
            .store(in: &cancellables)
        
        sendButton.tapPublisher.sink {
            guard let phoneNumberString = self.phoneNumberTextField.text else { return }
            Task {
                guard let smsCode = try await self.viewModel.phoneNumberVerify(phoneNumber: phoneNumberString) else { return }
                self.navigateToSMSCodeVerificationPage(phoneNumberString: phoneNumberString, smsCode: smsCode)
            }

        }.store(in: &cancellables)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height

            sendButtonBottomConstraints.constant = -keyboardHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        sendButtonBottomConstraints.constant = -Constraints.shared.space16
        view.layoutIfNeeded()
    }
}

extension PhoneNumberVerificationViewController {
    func navigateToSMSCodeVerificationPage(phoneNumberString: String, smsCode: String) {
        viewModel.phoneNumber = phoneNumberString
        viewModel.smsCode = smsCode
        self.navigationController?.pushViewController(SMSCodeVerificationViewController(viewModel: viewModel), animated: true)
    }
}
