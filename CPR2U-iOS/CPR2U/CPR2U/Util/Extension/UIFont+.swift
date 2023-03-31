//
//  UIFont+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/04.
//

import UIKit

enum FontWeight {
    case bold, regular
}

extension UIFont {
    
    convenience init?(weight: FontWeight, size: CGFloat) {
        switch weight {
        case .bold:
            self.init(name: "NotoSans-Bold", size: size)
        case .regular:
            self.init(name: "NotoSans-Regular", size: size)
        }
    }
    
}
