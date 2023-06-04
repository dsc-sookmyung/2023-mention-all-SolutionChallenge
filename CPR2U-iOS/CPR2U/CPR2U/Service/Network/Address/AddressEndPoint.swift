//
//  AddressEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/29.
//

import Foundation

enum AddressEndPoint {
    case setUserAddress(id: Int)
}

extension AddressEndPoint: EndPoint {
    
    var method: HttpMethod {
        switch self {
        case .setUserAddress:
            return .POST
        }
    }
    
    var body: Data? {
        var params: [String : Int]
        switch self {
        case .setUserAddress(let id):
            params = ["address_id": id]
        }
        
        return params.encode()
    }
    
    func getURL(path: String) -> String {
        let baseURL = URLs.baseURL
        switch self {
        case .setUserAddress:
            return "\(baseURL)/users/address"
        }
    }
    
    func createRequest() -> NetworkRequest {
        let baseURL = URLs.baseURL
        var headers: [String: String] = [:]
        headers["Authorization"] = UserDefaultsManager.accessToken

        switch self {
        case .setUserAddress:
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        }
    }
}

