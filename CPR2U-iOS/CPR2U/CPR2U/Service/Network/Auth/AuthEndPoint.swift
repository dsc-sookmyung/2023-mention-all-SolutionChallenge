//
//  AuthEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/11.
//

import Foundation

enum AuthEndPoint {
    case phoneNumberVerify (phoneNumber: String)
    case nicknameVerify (nickname: String)
    case signIn (phoneNumber: String, deviceToken: String)
    case signUp (nickname: String, phoneNumber: String, deviceToken: String)
    case autoLogin (refreshToken: String)
}

extension AuthEndPoint: EndPoint {
    
    var method: HttpMethod {
        switch self {
        case .phoneNumberVerify, .signIn, .signUp, .autoLogin:
            return .POST
        case .nicknameVerify:
            return .GET
        }
    }
    
    var body: Data? {
        var params: [String : String]
        switch self {
        case .phoneNumberVerify(let phoneNumber):
            params = ["phone_number" : phoneNumber]
        case .nicknameVerify(let nickname):
            params = ["nickname" : nickname ]
        case .signIn(let phoneNumber, let deviceToken):
            params = [ "phone_number" : phoneNumber, "device_token" : deviceToken ]
        case .signUp(let nickname, let phoneNumber, let deviceToken):
            params = ["nickname" : nickname, "phone_number" : phoneNumber, "device_token" : deviceToken ]
        case .autoLogin(let refreshToken) :
            params = ["refresh_token" : refreshToken]
        }
        
        return params.encode()
    }
    
    func getURL(path: String) -> String {
        let baseURL = URLs.baseURL
        switch self {
        case .phoneNumberVerify:
            return "\(baseURL)/auth/verification"
        case .nicknameVerify(let nickname):
            return "\(baseURL)/auth/nickname?nickname=\(nickname)"
        case .signIn:
            return "\(baseURL)/auth/login"
        case .signUp:
            return "\(baseURL)/auth/signup"
        case .autoLogin:
            return "\(baseURL)/auth/auto-login"
        }
    }
    
    func createRequest() -> NetworkRequest {
        let baseURL = URLs.baseURL
        switch self {
        case .phoneNumberVerify:
            var headers: [String: String] = [:]
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        case .nicknameVerify:
            var headers: [String: String] = [:]
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers)
        case .signIn:
            var headers: [String: String] = [:]
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        case .signUp:
            var headers: [String: String] = [:]
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        case .autoLogin:
            var headers: [String: String] = [:]
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method,
                                  headers: headers,
                                  requestBody: body)
        }
    }
}
