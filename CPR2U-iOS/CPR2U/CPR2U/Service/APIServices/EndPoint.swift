//
//  EndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation

protocol EndPoint {
    var method: HttpMethod { get }
    var body: Data? { get }
    
    func getURL(path: String) -> String
    func createRequest() -> NetworkRequest
}

extension EndPoint {
    func createRequest() -> NetworkRequest {
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        return NetworkRequest(url: getURL(path: URLs.baseURL),
                              httpMethod: method,
                              headers: headers,
                              requestBody: body)
    }
}
