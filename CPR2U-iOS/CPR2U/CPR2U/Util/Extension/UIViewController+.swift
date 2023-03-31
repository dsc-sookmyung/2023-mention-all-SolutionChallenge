//
//  UIViewController+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/06.
//

import UIKit

extension UIViewController {
    // https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setUpOrientation(as status: UIInterfaceOrientationMask) {
        UIApplication.shared.isIdleTimerDisabled = true
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = status
        }
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
