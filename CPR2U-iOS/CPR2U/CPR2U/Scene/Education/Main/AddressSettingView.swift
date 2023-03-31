//
//  AddressSettingView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/29.
//

import Combine
import CombineCocoa
import UIKit

// TODO: 추후 CustomNoticeView 상속 받아서 사용하는 형태로 변경하기
final class AddressSettingView: UIView {
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(weight: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .mainBlack
        label.text = "Select your address for\nCPR Angel activities"
        return label
    }()
    
    private lazy var mainAddressTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(weight: .bold, size: 24)
        textField.textColor = UIColor(rgb: 0xC1C1C1)
        textField.textAlignment = .center
        textField.tintColor = .clear
        textField.text = "시/도"
        return textField
    }()
    
    private lazy var subAddressTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(weight: .bold, size: 24)
        textField.textColor = UIColor(rgb: 0xC1C1C1)
        textField.textAlignment = .center
        textField.tintColor = .clear
        textField.text = "구/군"
        return textField
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
    
    private var addressList: [AddressListResult] = []
    private var mainAddressIndex: Int?
    private var addressId: Int?
    private let addressManager = AddressManager(service: APIManager())
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(frame: CGRect.zero)
        setUpConstraints()
        setUpStyle()
        setUpAction()
        
        Task {
            setUpAddreessList()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        self.addSubview(noticeView)
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            noticeView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            noticeView.widthAnchor.constraint(equalToConstant: 313),
            noticeView.heightAnchor.constraint(equalToConstant: 308)
        ])
        
        [
            titleLabel,
            mainAddressTextField,
            subAddressTextField,
            confirmButton
        ].forEach({
            noticeView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: noticeView.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: noticeView.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            mainAddressTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            mainAddressTextField.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            mainAddressTextField.widthAnchor.constraint(equalTo: noticeView.widthAnchor),
            mainAddressTextField.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        NSLayoutConstraint.activate([
            subAddressTextField.topAnchor.constraint(equalTo: mainAddressTextField.bottomAnchor, constant: 24),
            subAddressTextField.centerXAnchor.constraint(equalTo: noticeView.centerXAnchor),
            subAddressTextField.widthAnchor.constraint(equalTo: noticeView.widthAnchor),
            subAddressTextField.heightAnchor.constraint(equalToConstant: 34)
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
    
    private func setUpAddreessList() {
        Task {
            let result = try await addressManager.getAddressList()
            if result.success == true {
                guard let list = result.data else { return }
                addressList = list
                setUpPickerView()
            }
            
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
        confirmButton.tapPublisher.sink {
            Task {
                guard let id = self.addressId else {
                    return }
                try await self.addressManager.setUserAddress(id: id)
                self.noticeDisappear()
            }
        }.store(in: &cancellables)
    }
    
    @objc func didSelectButtonTapped() {
        mainAddressTextField.endEditing(true)
        subAddressTextField.endEditing(true)
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

extension AddressSettingView: UIPickerViewDelegate, UIPickerViewDataSource {
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
                addressId = addressList[row].gugun_list[0].id
                subAddressTextField.isHidden = true
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
            addressId = addressList[index].gugun_list[row].id
        }
    }
}
