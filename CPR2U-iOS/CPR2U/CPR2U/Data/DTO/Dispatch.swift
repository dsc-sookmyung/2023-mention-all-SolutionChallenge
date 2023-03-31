//
//  Dispatch.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/30.
//

import Foundation

struct DispatchInfo: Codable {
    let latitude: Double
    let longitude: Double
    let dispatch_id: Int
    let full_address: String
    let called_at: String
}

struct ReportInfo: Codable {
    let content: String
    let dispatch_id: Int
}

struct ReportResult: Codable { }

struct DispatchEndResult: Codable { }
