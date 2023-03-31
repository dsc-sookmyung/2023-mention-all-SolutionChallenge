//
//  Int+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/26.
//

import Foundation

extension Int {
    func numberAsTime() -> String {
        let mValue = self/60
        let sValue = self%60
        
        let minuteStr = mValue < 10 ? "0\(mValue)" : "\(mValue)"
        let secondStr = sValue < 10 ? "0\(sValue)" : "\(sValue)"
        return "\(minuteStr):\(secondStr)"
    }
    
    func numberAsExpirationDate() -> String {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = self
        guard let expirationDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) else { return "" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: expirationDate)
    }
}
