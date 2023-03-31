//
//  CallEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/26.
//

import Foundation

enum CallEndPoint {
    case getCallerList
    case callDispatcher(callerLocationInfo: CallerLocationInfo)
    case situationEnd(callId: Int)
    case countDispatcher(callId: Int)
}

extension CallEndPoint: EndPoint {
    
    var method: HttpMethod {
        switch self {
        case .callDispatcher, .situationEnd:
            return .POST
        case .getCallerList, .countDispatcher:
            return .GET
        }
    }
    
    var body: Data? {
        switch self {
        case .getCallerList:
            return nil
        case .callDispatcher(let callerLocationInfo):
            return callerLocationInfo.encode()
        case .situationEnd, .countDispatcher:
            return nil
        }
    }
    
    func getURL(path: String) -> String {
        let baseURL = URLs.baseURL
        switch self {
        case .getCallerList:
            return "\(baseURL)/call"
        case .callDispatcher:
            return "\(baseURL)/call"
        case .situationEnd(let callId):
            return "\(baseURL)/call/end/\(callId)"
        case .countDispatcher(let callId):
            return "\(baseURL)/call/\(callId)"
        }
    }
    
    func createRequest() -> NetworkRequest {
        let baseURL = URLs.baseURL
        var headers: [String: String] = [:]
        headers["Authorization"] = UserDefaultsManager.accessToken
        switch self {
        case .getCallerList:
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers)
        case .callDispatcher:
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers, requestBody: body)
        case .situationEnd:
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers)
        case .countDispatcher:
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers)
        }
    }
}
