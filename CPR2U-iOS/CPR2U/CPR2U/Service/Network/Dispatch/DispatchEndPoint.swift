//
//  DispatchEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/30.
//

import Foundation

enum DispatchEndPoint {
    case dispatchAccept(cprCallId: Int)
    case userReport(reportInfo: ReportInfo)
    case dispatchEnd(dispatchId: Int)
}

extension DispatchEndPoint: EndPoint {
    
    var method: HttpMethod {
        switch self {
        case .dispatchAccept, .userReport, .dispatchEnd:
            return .POST
        }
    }
    
    var body: Data? {
        var params: [String: Int]
        switch self {
        case .dispatchAccept(let cprCallId):
            params = ["cpr_call_id": cprCallId]
        case .userReport(let reportInfo):
            return reportInfo.encode()
        case .dispatchEnd(let dispatchId):
            params = ["dispatch_id": dispatchId]
        }
        return params.encode()
    }
    
    func getURL(path: String) -> String {
        let baseURL = URLs.baseURL
        switch self {
        case .dispatchAccept:
            return "\(baseURL)/dispatch"
        case .userReport:
            return "\(baseURL)/dispatch/report"
        case .dispatchEnd(let dispatchId):
            return "\(baseURL)/dispatch/arrive/\(dispatchId)"
        }
    }
    
    func createRequest() -> NetworkRequest {
        let baseURL = URLs.baseURL
        var headers: [String: String] = [:]
        headers["Authorization"] = UserDefaultsManager.accessToken
        switch self {
        case .dispatchAccept:
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers, requestBody: body)
        case .userReport:
            headers["Content-Type"] = "application/json"
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers, requestBody: body)
        case .dispatchEnd:
            return NetworkRequest(url: getURL(path: baseURL), httpMethod: method, headers: headers)
        }
    }
}
