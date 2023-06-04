//
//  UITextField+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/05/24.
//  https://stackoverflow.com/questions/2694411/text-inset-for-uitextfield

import UIKit

class TextField: UITextField {
    let inset: CGFloat = 10

    // placeholder position
    override func textRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: self.inset , dy: self.inset)
    }

    // text position
    override func editingRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: self.inset , dy: self.inset)
    }

    override func placeholderRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: self.inset, dy: self.inset)
    }
}
