//
//  AddressEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/29.
//

import Foundation

enum AddressEndPoint {
    case getAddressList
    case setUserAddress(id: Int)
}

extension AddressEndPoint: EndPoint {
    
    var method: HttpMethod {
        switch self {
        case .setUserAddress:
            return .POST
        case .getAddressList:
            return .GET
        }
    }
    
    var body: Data? {
        var params: [String : Int]
        switch self {
        case .getAddressList:
            return nil
        case .setUserAddress(let id):
            params = ["address_id": id]
        }
        
        return params.encode()
    }
    
    func getURL(path: String) -> String {
        let baseURL = URLs.baseURL
        switch self {
        case .getAddressList:
            return "\(baseURL)/users/address"
        case .setUserAddress:
            return "\(baseURL)/users/address"
        }
    }
    
    func createRequest() -> NetworkRequest {
        let baseURL = URLs.baseURL
        var headers: [String: String] = [:]
        headers["Authorization"] = UserDefaultsManager.accessToken

        switch self {
        case .getAddressList:
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers)
        case .setUserAddress:
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        }
    }
}

