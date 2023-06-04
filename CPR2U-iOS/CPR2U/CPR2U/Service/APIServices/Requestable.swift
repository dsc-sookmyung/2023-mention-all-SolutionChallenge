//
//  Requestable.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation


protocol Requestable: AnyObject {
    func request<T: Decodable>(_ request: NetworkRequest) async throws -> (success: Bool, data: T?)
}

final class APIManager: Requestable {
    func request<T: Decodable>(_ request: NetworkRequest) async throws -> (success: Bool, data: T?) {
        guard let encodedURL = request.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw APIError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request.createURLRequest(with: url))
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<500) ~= httpResponse.statusCode else {
            throw APIError.serverError
        }
        
        let decodedData = try JSONDecoder().decode(NetworkResponse<T>.self, from: data)
        
        if decodedData.status == 200 {
            return (true, decodedData.data)
        } else {
            return (false, decodedData.data)
        }
        
    }
}
