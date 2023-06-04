//
//  SMSCodeInputView.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/04.
//

import UIKit

final class SMSCodeInputView: UIView {

    private var isHighlight = true {
        didSet(oldValue) {
            if oldValue == true {
                self.backgroundColor = .mainLightRed
                self.layer.borderWidth = 0
            } else {
                self.backgroundColor = .white
                self.layer.borderWidth = 2
            }
        }
    }
    var smsCodeTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(weight: .regular, size: 29)
        textField.textColor = UIColor(rgb: 0xAC6767)
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        return textField
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
        
        self.addSubview(smsCodeTextField)
        smsCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            smsCodeTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            smsCodeTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            smsCodeTextField.widthAnchor.constraint(equalToConstant: 64),
            smsCodeTextField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func setUpStyle() {
        self.backgroundColor = UIColor(rgb: 0xFBD6D6)
        
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.mainBlack.cgColor
        self.layer.borderWidth = 0
    }
    
}
