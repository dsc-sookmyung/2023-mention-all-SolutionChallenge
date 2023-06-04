//
//  AuthEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/11.
//

import Foundation

struct AnyEncodable: Encodable {
    private let encodable: Encodable

    init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

enum AuthEndPoint {
    case phoneNumberVerify (phoneNumber: String)
    case nicknameVerify (nickname: String)
    case signIn (phoneNumber: String, deviceToken: String)
    case signUp (nickname: String, phoneNumber: String, addressId: Int, deviceToken: String)
    case autoLogin (refreshToken: String)
    case logOut
    case getAddressList
}

extension AuthEndPoint: EndPoint {
    
    var method: HttpMethod {
        switch self {
        case .phoneNumberVerify, .signIn, .signUp, .autoLogin, .logOut:
            return .POST
        case .nicknameVerify, .getAddressList:
            return .GET
        }
    }
    
    var body: Data? {
        var params: [String : AnyEncodable]
        switch self {
        case .phoneNumberVerify(let phoneNumber):
            params = ["phone_number" : AnyEncodable(phoneNumber)]
        case .nicknameVerify(let nickname):
            params = ["nickname" : AnyEncodable(nickname)]
        case .signIn(let phoneNumber, let deviceToken):
            params = [ "phone_number" : AnyEncodable(phoneNumber), "device_token" : AnyEncodable(deviceToken)]
        case .signUp(let nickname, let phoneNumber, let addressId, let deviceToken):
            params = ["nickname" : AnyEncodable(nickname), "phone_number" : AnyEncodable(phoneNumber), "address_id" :
                        AnyEncodable(addressId), "device_token" : AnyEncodable(deviceToken)]
        case .autoLogin(let refreshToken) :
            params = ["refresh_token" : AnyEncodable(refreshToken)]
        case .getAddressList:
            return nil
        case .logOut :
            return nil
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
        case .getAddressList:
            return "\(baseURL)/auth/address"
        case .logOut:
            return "\(baseURL)/auth/logout"
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
        case .logOut:
            var headers: [String: String] = [:]
            headers["Authorization"] = UserDefaultsManager.accessToken
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers)
        case .getAddressList:
            return NetworkRequest(url: getURL(path: baseURL),
                                  httpMethod: method)
        }
    }
}
