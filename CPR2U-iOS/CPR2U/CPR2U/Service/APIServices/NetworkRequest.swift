//
//  NetworkRequest.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation

struct NetworkRequest {
    let url: String
    let httpMethod: HttpMethod
    let headers: [String: String]?
    let body: Data?
    
    init(url: String,
         httpMethod: HttpMethod,
         headers: [String: String]? = nil,
         requestBody: Data? = nil
    ) {
        self.url = url
        self.httpMethod = httpMethod
        self.body = requestBody
        self.headers = headers
    }
    
    func createURLRequest(with url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers ?? [:]
        urlRequest.httpBody = body
        return urlRequest
    }
}
