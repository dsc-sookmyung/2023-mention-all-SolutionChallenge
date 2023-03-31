//
//  Address.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/29.
//

import Foundation

struct AddressListResult: Codable {
    let sido: String
    let gugun_list: [SubAddress]
}

struct SubAddress: Codable {
    let id: Int
    let gugun: String
}

struct SetUserAddressResult: Codable { }
