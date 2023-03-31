//
//  NetworkResponse.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation

struct NetworkResponse<T: Decodable>: Decodable {
    var status: Int
    var message: String?
    var data: T?
}
