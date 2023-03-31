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

    private let instructionLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let phoneNumberView = UIView()
    private let phoneNumberNationView = UIView()
    private let phoneNumberNationLabel = UILabel()
    private let phoneNumberTextField = UITextField()
    
    private let sendButton: UIButton = {
        let button = UIButton()
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
        setUpText()
        setUpKeyboard()
        bind(to: viewModel)
    }
    
    private func setUpConstraints() {
        
        let space4: CGFloat = 4
        let space8: CGFloat = 8
        let space16: CGFloat = 16
        
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
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: space16),
            instructionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: space16),
            instructionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -space16),
            instructionLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: space4),
            descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: space16),
            descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: space16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 28)
        ])

        NSLayoutConstraint.activate([
            phoneNumberView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: space8),
            phoneNumberView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: space16),
            phoneNumberView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -space16),
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
            phoneNumberTextField.leadingAnchor.constraint(equalTo: phoneNumberNationView.trailingAnchor, constant: space16),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: phoneNumberView.trailingAnchor),
            phoneNumberTextField.heightAnchor.constraint(equalTo: phoneNumberView.heightAnchor)
        ])

        sendButtonBottomConstraints = sendButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -space16)
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: space16),
            sendButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -space16),
            sendButtonBottomConstraints,
            sendButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setUpStyle() {
        
        view.backgroundColor = .white
        
        instructionLabel.font = UIFont(weight: .bold, size: 24)
        instructionLabel.textColor = .mainBlack
        descriptionLabel.font = UIFont(weight: .regular, size: 14)
        descriptionLabel.textColor = .mainBlack
        
        phoneNumberNationView.clipsToBounds = true
        phoneNumberNationView.layer.cornerRadius = 6
        phoneNumberNationView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        phoneNumberNationView.backgroundColor = UIColor(rgb:0xF2F2F2)
        
        phoneNumberNationLabel.font = UIFont(weight: .regular, size: 15)
        phoneNumberNationLabel.textAlignment = .center
        phoneNumberNationLabel.textColor = .mainBlack
        
        phoneNumberView.layer.borderColor = UIColor(rgb:0xF2F2F2).cgColor
        phoneNumberView.layer.borderWidth = 1
        phoneNumberView.layer.cornerRadius = 6
        
        phoneNumberTextField.backgroundColor = .clear
        phoneNumberTextField.textColor = .mainBlack
        phoneNumberTextField.font = UIFont(weight: .regular, size: 16)
        
        sendButton.titleLabel?.font = UIFont(weight: .bold, size: 16)
        sendButton.setTitleColor(.mainBlack, for: .normal)
        sendButton.backgroundColor = .mainLightGray
        sendButton.layer.cornerRadius = 27.5
    }
    
    private func setUpText() {
        instructionLabel.text = "Enter your number"
        descriptionLabel.text = "We will send a code to verify your mobile number"
        
        phoneNumberNationLabel.text = "+ 82"
        
        phoneNumberTextField.placeholder = "PhoneNumber*"
        sendButton.setTitle("SEND", for: .normal)
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
            .buttonIsValid
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
        sendButtonBottomConstraints.constant = -16
        view.layoutIfNeeded()
    }
}

extension PhoneNumberVerificationViewController {
    func navigateToSMSCodeVerificationPage(phoneNumberString: String, smsCode: String) {
        viewModel.setPhoneNumber(number: phoneNumberString)
        viewModel.setSMSCode(number: smsCode)
        self.navigationController?.pushViewController(SMSCodeVerificationViewController(viewModel: viewModel), animated: true)
    }
}
