//
//  AddressVerificationViewController.swift
//  CPR2U
//
//  Created by 황정현 on 2023/05/24.
//

import Combine
import UIKit

final class AddressVerificationViewController: UIViewController {

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 24)
        label.textColor = .mainBlack
        label.text = "address_ins_txt".localized()
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .regular, size: 14)
        label.textColor = .mainBlack
        label.text = "address_des_txt".localized()
        return label
    }()
    
    private lazy var mainAddressTextField: TextField = {
        let textField = TextField()
        textField.font = UIFont(weight: .regular, size: 16)
        textField.textColor = UIColor(rgb: 0xC1C1C1)
        textField.textAlignment = .left
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 6
        textField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        textField.tintColor = .clear
        textField.text = "시/도"
        return textField
    }()
    
    private lazy var subAddressTextField: TextField = {
        let textField = TextField()
        textField.font = UIFont(weight: .regular, size: 16)
        textField.textColor = UIColor(rgb: 0xC1C1C1)
        textField.textAlignment = .left
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 6
        textField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        textField.tintColor = .clear
        textField.text = "구/군"
        return textField
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
    
    private var addressList: [AddressListResult] = []
    private var mainAddressIndex: Int?
    private var addressId: Int?
    
    private let addressManager = AddressManager(service: APIManager())
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
        bind(viewModel: viewModel)
        
        Task {
            setUpAddreessList()
        }
    }
    
    private func setUpConstraints() {
        let make = Constraints.shared
        let safeArea = view.safeAreaLayoutGuide
        
        [
            instructionLabel,
            descriptionLabel,
            mainAddressTextField,
            subAddressTextField,
            continueButton
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
            descriptionLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        NSLayoutConstraint.activate([
            mainAddressTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            mainAddressTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: make.space16),
            mainAddressTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -make.space16),
            mainAddressTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            subAddressTextField.topAnchor.constraint(equalTo: mainAddressTextField.bottomAnchor, constant: make.space8),
            subAddressTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: make.space16),
            subAddressTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -make.space16),
            subAddressTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: make.space16),
            continueButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -make.space16),
            continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -make.space16),
            continueButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
    }
    
    private func setUpStyle() {
        view.backgroundColor = .white
    }
    
    private func bind(viewModel: AuthViewModel) {
        continueButton.tapPublisher.sink { [weak self] in
            Task {
                let signUpResult = try await self?.viewModel.signUp()
                if signUpResult == true {
                    self?.dismiss(animated: true)
                    let vc = TabBarViewController()
                    guard let window = self?.view.window else { return }
                    await window.setRootViewController(vc, animated: true)
                } else {
                    print("에러")
                }
            }
        }.store(in: &cancellables)
    }
    
    private func setUpAddreessList() {
        Task {
            guard let data = try await viewModel.getAddressList() else { return }
            addressList = data
            setUpPickerView()
        }
    }
    
    private func setUpPickerView() {
        let mainPickerView = UIPickerView()
        mainPickerView.layer.name = "mainPickerView"
        let subPickerView = UIPickerView()
        subPickerView.layer.name = "subPickerView"
        
        [mainPickerView, subPickerView].forEach({
            $0.delegate = self
            $0.dataSource = self
        })
        
        [mainAddressTextField, subAddressTextField].forEach({
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let button = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(self.didSelectButtonTapped))
            toolBar.setItems([button], animated: true)
            toolBar.isUserInteractionEnabled = true
            $0.inputAccessoryView = toolBar
        })
        
        mainAddressTextField.inputView = mainPickerView
        subAddressTextField.inputView = subPickerView
    }
    
    private func setUpAction() {
        continueButton.tapPublisher.sink {
            Task { [weak self] in
                guard let self = self else { return }
                let signUpResult = try await self.viewModel.signUp()
                if signUpResult == true {
                    self.dismiss(animated: true)
                    let vc = TabBarViewController()
                    guard let window = self.view.window else { return }
                    await window.setRootViewController(vc, animated: true)
                } else {
                    print("에러")
                }
            }
        }.store(in: &cancellables)
    }
    
    @objc func didSelectButtonTapped() {
        mainAddressTextField.endEditing(true)
        subAddressTextField.endEditing(true)
    }
}

extension AddressVerificationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.layer.name == "mainPickerView" {
            return 1
        } else if pickerView.layer.name == "subPickerView" {
            return 1
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.layer.name == "mainPickerView" {
            return addressList.count
        } else if pickerView.layer.name == "subPickerView" {
            guard let index = mainAddressIndex else { return 0 }
            return addressList[index].gugun_list.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.layer.name == "mainPickerView" {
            return addressList[row].sido
        } else if pickerView.layer.name == "subPickerView" {
            guard let index = mainAddressIndex else { return "" }
            return addressList[index].gugun_list[row].gugun
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.layer.name == "mainPickerView" {
            mainAddressTextField.text = addressList[row].sido
            mainAddressTextField.textColor = .mainBlack
            if addressList[row].sido == "세종특별자치시" {
                viewModel.addressId = addressList[row].gugun_list[0].id
                subAddressTextField.isHidden = true
                print("ADDRESS ID IS \(viewModel.addressId)")
            } else {
                addressId = nil
                subAddressTextField.text = "구/군"
                subAddressTextField.textColor = UIColor(rgb: 0xC1C1C1)
                subAddressTextField.isHidden = false
            }
            mainAddressIndex = row
        } else if pickerView.layer.name == "subPickerView" {
            guard let index = mainAddressIndex else { return }
            subAddressTextField.text = addressList[index].gugun_list[row].gugun
            subAddressTextField.textColor = .mainBlack
            viewModel.addressId = addressList[index].gugun_list[row].id
            print("ADDRESS ID IS \(viewModel.addressId)")
        }
    }
}
