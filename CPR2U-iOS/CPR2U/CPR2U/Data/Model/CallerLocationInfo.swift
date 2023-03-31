//
//  CallerLocationInfo.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/26.
//

import Foundation

struct CallerLocationInfo: Encodable {
    let latitude: Double
    let longitude: Double
    let full_address: String
}
