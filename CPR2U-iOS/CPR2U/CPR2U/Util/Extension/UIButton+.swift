//
//  UIButton+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/13.
//

import UIKit

extension UIButton {
    func changeButtonStyle(isSelected: Bool) {
        backgroundColor = isSelected ? UIColor.mainRed : UIColor.mainRed.withAlphaComponent(0.05)
        setTitleColor(isSelected ? .mainWhite : .mainBlack, for: .normal)
    }

}
