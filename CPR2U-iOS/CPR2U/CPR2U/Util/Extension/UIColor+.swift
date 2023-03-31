//
//  UIColor+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/02.
//

import UIKit

extension UIColor {
    
    convenience init(rgb: Int) {
           self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1
           )
    }
    
    static let mainWhite = UIColor(rgb: 0xFFF6F6)
    
    static let mainBlack = UIColor(rgb: 0x19191B)
    static let mainDarkGray = UIColor(rgb: 0x595959)
    static let mainLightGray = UIColor(rgb: 0xD9D9D9)
    
    static let mainDarkRed = UIColor(rgb: 0xB50000)
    static let mainRed = UIColor(rgb: 0xF74346)
    static let mainLightRed = UIColor(rgb: 0xFBA1A2)
    
    static let subOrange = UIColor(rgb: 0xFC7037)
    static let subPink = UIColor(rgb: 0xFF0050)
    
}
