//
//  SMSCodeVerificationViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/04.
//

import Combine
import CombineCocoa
import UIKit

// TODO: UI/UX Question
final class SMSCodeVerificationViewController: UIViewController {
    private let authManager = AuthManager(service: APIManager())
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textColor = .mainBlack
        label.text = "code_ins_txt".localized()
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        label.text = "code_des_txt".localized()
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 16)
        label.textAlignment = .left
        label.textColor = .mainBlack
        label.text = "+82 \(self.viewModel.phoneNumber)"
        return label
    }()
    
    private let smsCodeInputView1 = SMSCodeInputView()
    private let smsCodeInputView2 = SMSCodeInputView()
    private let smsCodeInputView3 = SMSCodeInputView()
    private let smsCodeInputView4 = SMSCodeInputView()
    
    private let codeResendLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .right
        label.textColor = .mainRed
        label.text = "code_resend_ins_txt".localized()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(weight: .bold, size: 16)
        button.setTitleColor(.mainBlack, for: .normal)
        button.backgroundColor = .mainLightGray
        button.layer.cornerRadius = 27.5
        button.isUserInteractionEnabled = false
        button.setTitle("confirm".localized(), for: .normal)
        return button
    }()
    
    private var confirmButtonBottomConstraints = NSLayoutConstraint()
    
    private var smsCodeCheckArr = Array(repeating: false, count: 4) {
        willSet(newValue) {
            let status = newValue.allSatisfy({$0})
            confirmButton.setTitleColor(status ? .mainWhite : .mainBlack, for: .normal)
            confirmButton.backgroundColor = status ? .mainRed : .mainLightGray
            confirmButton.isUserInteractionEnabled = status
        }
    }
    
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
        setUpAction()
        setUpLayerName()
        setUpKeyboard()
        bind(viewModel: viewModel)
    }
    
    private func setUpConstraints() {
        
        let make = Constraints.shared
        let safeArea = view.safeAreaLayoutGuide
        
        let smsCodeInputStackView   = UIStackView()
        smsCodeInputStackView.axis  = NSLayoutConstraint.Axis.horizontal
        smsCodeInputStackView.distribution  = UIStackView.Distribution.equalSpacing
        smsCodeInputStackView.alignment = UIStackView.Alignment.center
        smsCodeInputStackView.spacing   = make.space12
        
        [
            instructionLabel,
            descriptionLabel,
            phoneNumberLabel,
            smsCodeInputStackView,
            codeResendLabel,
            confirmButton
        ].forEach({
            view.addSubview($0)
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
            descriptionLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        NSLayoutConstraint.activate([
            phoneNumberLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: make.space4),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            phoneNumberLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        self.view.addSubview(smsCodeInputStackView)
        smsCodeInputStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            smsCodeInputStackView.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: make.space16),
            smsCodeInputStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            smsCodeInputStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            smsCodeInputStackView.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        [
            smsCodeInputView1,
            smsCodeInputView2,
            smsCodeInputView3,
            smsCodeInputView4
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            smsCodeInputStackView.addArrangedSubview($0 as UIView)
            
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: smsCodeInputStackView.topAnchor),
                $0.widthAnchor.constraint(equalToConstant: 76),
                $0.heightAnchor.constraint(equalToConstant: 54)
            ])
        })
        
        NSLayoutConstraint.activate([
            codeResendLabel.topAnchor.constraint(equalTo: smsCodeInputStackView.bottomAnchor, constant: make.space8),
            codeResendLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            codeResendLabel.widthAnchor.constraint(equalToConstant: 300),
            codeResendLabel.heightAnchor.constraint(equalToConstant: 24),
            
        ])
        
        confirmButtonBottomConstraints = confirmButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16)
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            confirmButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            confirmButtonBottomConstraints,
            confirmButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func setUpLayerName() {
        let views = [smsCodeInputView1, smsCodeInputView2, smsCodeInputView3, smsCodeInputView4]
        for index in 0..<views.count {
            views[index].smsCodeTextField.layer.name = "\(index)"
        }
    }
    
    private func setUpKeyboard() {
        smsCodeInputView1.smsCodeTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    private func bind(viewModel: AuthViewModel) {
        let smsCodeViews = [smsCodeInputView1, smsCodeInputView2, smsCodeInputView3, smsCodeInputView4]
        
        for index in 0...3 {
            
            smsCodeViews[index].smsCodeTextField.controlEventPublisher(for: .editingDidBegin).sink {
                let textField = smsCodeViews[index].smsCodeTextField
                textField.text = ""
                guard let textFieldLayerName = textField.layer.name else { return }
                guard let index = Int(textFieldLayerName) else { return }
                self.smsCodeCheckArr[index] = false
            }
            .store(in: &cancellables)
            
            smsCodeViews[index].smsCodeTextField.textPublisher.sink {
                
                guard let textLength = $0?.count else { return }
                if textLength == 1 {
                    if index != 3 {
                        smsCodeViews[(index+1)].smsCodeTextField.becomeFirstResponder()
                        smsCodeViews[(index+1)].smsCodeTextField.text = ""
                    }
                    self.smsCodeCheckArr[index] = true
                } else if textLength > 1 && index == 3 {
                    smsCodeViews[(index)].smsCodeTextField.text?.removeFirst()
                }
            }
            .store(in: &cancellables)
        }
        
        confirmButton.tapPublisher.sink { [self] in
            Task {
                if smsCodeVerify() {
                    // MARK: 회원가입 관련 userVerify 메소드는 NicknameVC에서 호출 예정
                    let isUser = try await viewModel.userVerify()
                    print("USER CHECK: ", isUser)
                    if isUser {
                        let vc = TabBarViewController()
                        guard let window = self.view.window else { return }
                        await window.setRootViewController(vc, animated: true)
                        dismiss(animated: true)
                    } else {
                        navigationController?.pushViewController(NicknameVerificationViewController(viewModel: viewModel), animated: true)
                    }
                } else {
                    print("인증코드 오류")
                }
            }
        }.store(in: &cancellables)
    }
    
    private func setUpAction() {
        let tapGesture = UITapGestureRecognizer()
        
        codeResendLabel.addGestureRecognizer(tapGesture)
        tapGesture.tapPublisher.sink { [weak self] _ in
            Task {
                guard let phoneNumber = self?.viewModel.phoneNumber else { return }
                _ = try await self?.viewModel.phoneNumberVerify(phoneNumber: phoneNumber)
            }
        }.store(in: &cancellables)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            confirmButtonBottomConstraints.constant = -keyboardHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        confirmButtonBottomConstraints.constant = Constraints.shared.space16
        view.layoutIfNeeded()
    }
}

extension SMSCodeVerificationViewController {
    func smsCodeVerify() -> Bool {
        let userInput = [smsCodeInputView1, smsCodeInputView2, smsCodeInputView3, smsCodeInputView4]
            .compactMap{$0.smsCodeTextField.text}
            .reduce("") { return $0 + $1 }
        return userInput == viewModel.smsCode
    }
}
