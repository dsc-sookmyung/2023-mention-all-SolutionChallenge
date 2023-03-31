//
//  APIError.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation

enum APIError: Error {
    case encodingError
    case serverError
    case clientError
}
