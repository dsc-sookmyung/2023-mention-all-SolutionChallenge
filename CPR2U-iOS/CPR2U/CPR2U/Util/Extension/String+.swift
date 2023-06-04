//
//  String+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/05/11.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func elapsedTime() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        guard let date = dateFormatter.date(from: self) else { return 0 }
        return Int(-date.timeIntervalSinceNow)
    }
}
