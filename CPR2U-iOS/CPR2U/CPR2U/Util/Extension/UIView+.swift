//
//  UIView+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/21.
//

import UIKit

enum ToastMessage: Equatable {
    case login(nickname: String)
    case education
    
    func toastMessage() -> String {
        switch self {
        case .login(let nickname):
            return "‘\(nickname)’ is Available"
        case .education:
            return "You must achieve 100% of your previous course progress."
        }
    }
}
 extension UIView {

     func showToastMessage(type: ToastMessage) {
         let width = UIScreen.main.bounds.width
         let height = UIScreen.main.bounds.height

         let toastLabel = UILabel()

         let margin = 8

         let labelYPos = type == .education ? Int(height * 0.78) : Int(height * 0.88)
         let labelHeight = type == .education ? 80 : 45
         toastLabel.frame = CGRect(x: margin, y: labelYPos, width: Int(width) - margin * 2, height: labelHeight)

         toastLabel.font = UIFont(weight: .bold, size: 14)
         toastLabel.text = type.toastMessage()
         toastLabel.numberOfLines = 2
         toastLabel.textColor = .mainWhite
         toastLabel.backgroundColor = .mainBlack
         toastLabel.textAlignment = .center
         toastLabel.layer.cornerRadius = 8
         toastLabel.clipsToBounds = true
         toastLabel.isUserInteractionEnabled = false
         toastLabel.layer.opacity = 0
         self.addSubview(toastLabel)

         UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
             toastLabel.layer.opacity = 1.0
         }, completion: {_ in
             UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseOut, animations: {
                 toastLabel.layer.opacity = 0
             }, completion: {_ in
                 toastLabel.removeFromSuperview()
             })
         })
     }
     
     func parentViewController() -> UIViewController {
         var responder: UIResponder? = self
         while !(responder is UIViewController) {
             responder = responder?.next
             if nil == responder {
                 break
             }
         }
         return (responder as? UIViewController)!
     }

 }
