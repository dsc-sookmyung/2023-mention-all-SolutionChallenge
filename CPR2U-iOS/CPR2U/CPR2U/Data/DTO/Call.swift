//
//  Call.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/26.
//

import Foundation

struct CallerListInfo: Codable {
    let angel_status: String
    let is_patient: Bool
    let call_list: [CallerInfo]
}

struct CallerInfo: Codable {
    let latitude: Double
    let longitude: Double
    let cpr_call_id: Int
    let full_address: String
    let called_at: String
}

struct CallResult: Codable {
    let call_id: Int
}

struct CallEndResult:Codable { }

struct DispatcherCountResult: Codable {
    let number_of_angels: Int
}
