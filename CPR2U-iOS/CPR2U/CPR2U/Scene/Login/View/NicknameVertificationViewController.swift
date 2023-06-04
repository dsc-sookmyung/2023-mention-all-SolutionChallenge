//
//  NicknameVerificationViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/04.
//

import Combine
import CombineCocoa
import UIKit

enum NicknameStatus {
    case specialCharacters
    case unavailable
    case available
    case none
    
    func changeNoticeLabel(noticeLabel: UILabel, nickname: String?) {
        
        let name = nickname ?? ""
        var str: String
        switch self {
        case .specialCharacters:
            str = "nickname_special_character".localized()
        case .unavailable:
            let localizedStr = String(format: "%@_nickname_unavailable".localized(), name)
            str = localizedStr
        case .available:
            str = ""
        case .none:
            str = ""
        }
        
        noticeLabel.text = str
        
    }
    
    func changeNoticeViewLayerBorderColor(view: UIView) {
        if self == .unavailable {
            view.layer.borderColor = UIColor.mainRed.cgColor
        } else {
            view.layer.borderColor = UIColor(rgb:0xF2F2F2).cgColor
        }
    }
}

final class NicknameVerificationViewController: UIViewController {

    private let signManager = AuthManager(service: APIManager())
    
    // MARK: 기존 회원인 경우와 기존 회원이 아닌 경우를 나누어서 처리가 이루어져야함
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textColor = .mainBlack
        label.text = "nickname_ins_txt".localized()
        return label
    }()
    
    // MARK: 기존 회원인 경우와 기존 회원이 아닌 경우를 나누어서 처리가 이루어져야함
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        label.text = "nickname_des_txt".localized()
        return label
    }()
    
    private let nicknameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(rgb:0xF2F2F2).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .mainBlack
        textField.font = UIFont(weight: .regular, size: 16)
        textField.placeholder = "nickname_phdr".localized()
        return textField
    }()
    
    private let irregularNoticeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textAlignment = .left
        label.textColor = .mainRed
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(weight: .bold, size: 16)
        button.setTitle("continue".localized(), for: .normal)
        button.setTitleColor(.mainWhite, for: .normal)
        button.backgroundColor = .mainRed
        button.layer.cornerRadius = 27.5
        return button
    }()
    
    private var continueButtonBottomConstraints = NSLayoutConstraint()
    
    private var nicknameStatus: NicknameStatus = NicknameStatus.none {
        willSet(newValue) {
            newValue.changeNoticeLabel(noticeLabel: irregularNoticeLabel, nickname: nicknameTextField.text)
            newValue.changeNoticeViewLayerBorderColor(view: nicknameView)
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
        setUpKeyboard()
        bind(viewModel: viewModel)
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        let safeArea = view.safeAreaLayoutGuide
        
        [
            instructionLabel,
            descriptionLabel,
            nicknameView,
            irregularNoticeLabel,
            continueButton
        ].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        nicknameView.addSubview(nicknameTextField)
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        
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
            nicknameView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: make.space8),
            nicknameView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            nicknameView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            nicknameView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: nicknameView.topAnchor),
            nicknameTextField.leadingAnchor.constraint(equalTo: nicknameView.leadingAnchor, constant: make.space16),
            nicknameTextField.trailingAnchor.constraint(equalTo: nicknameView.trailingAnchor),
            nicknameTextField.heightAnchor.constraint(equalTo: nicknameView.heightAnchor)
        ])

        NSLayoutConstraint.activate([
            irregularNoticeLabel.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: make.space8),
            irregularNoticeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            irregularNoticeLabel.widthAnchor.constraint(equalToConstant: 300),
            irregularNoticeLabel.heightAnchor.constraint(equalToConstant: 16),
        ])
        
        continueButtonBottomConstraints = continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16)
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            continueButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            continueButtonBottomConstraints,
            continueButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func setUpAction() {
        nicknameTextField.textPublisher.sink { [weak self] text in
            guard let text else { return }
            
            if text.count > 20 {
                self?.nicknameTextField.text?.removeLast()
            }
            
            let strArr = Array(text)
            let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]$"
            
            if strArr.count > 0 {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    for index in 0..<strArr.count {
                        let checkString = regex.matches(in: String(strArr[index]), options: [], range: NSRange(location: 0, length: 1))
                        if checkString.count == 0 {
                            self?.nicknameStatus = .specialCharacters
                            return
                        }
                    }
                }
                self?.nicknameStatus = .none
            } else {
                self?.nicknameStatus = .none
            }
        }.store(in: &cancellables)
    }
    
    private func setUpKeyboard() {
        nicknameTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    private func bind(viewModel: AuthViewModel) {
        // MARK: 기존 회원인 경우와 기존 회원이 아닌 경우를 나누어서 처리할 예정
        continueButton.tapPublisher.sink { [weak self] in
            guard let userInput = self?.nicknameTextField.text else { return }
            Task {
                guard let self = self, userInput.count > 0 else { return }
                if (self.nicknameStatus != .specialCharacters) {
                    let nicknameStatus = try await self.viewModel.nicknameVerify(userInput: userInput)
                    if nicknameStatus == .available {
                        viewModel.nickname = userInput
                        self.navigationController?.pushViewController(AddressVerificationViewController(viewModel: viewModel), animated: true)
                    } else {
                        nicknameStatus.changeNoticeLabel(noticeLabel: self.irregularNoticeLabel, nickname: userInput)
                    }
                }
            }
        }.store(in: &cancellables)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height

            continueButtonBottomConstraints.constant = -keyboardHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        continueButtonBottomConstraints.constant = -Constraints.shared.space16
        view.layoutIfNeeded()
    }
}
