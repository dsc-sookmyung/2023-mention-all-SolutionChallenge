//
//  DispatchManager.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/30.
//

import Foundation

protocol DispatchService {
    func dispatchAccept(cprCallId: Int) async throws -> (success: Bool, data: DispatchInfo?)
    func userReport(reportInfo: ReportInfo) async throws -> (success: Bool, data: ReportResult?)
    func dispatchEnd(dispatchId: Int) async throws -> (success: Bool, data: DispatchEndResult?)
}

struct DispatchManager: DispatchService {
    private let service: Requestable
    
    init(service: Requestable) {
        self.service = service
    }
    
    func dispatchAccept(cprCallId: Int) async throws -> (success: Bool, data: DispatchInfo?) {
        let request = DispatchEndPoint
            .dispatchAccept(cprCallId: cprCallId)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func userReport(reportInfo: ReportInfo) async throws -> (success: Bool, data: ReportResult?) {
        let request = DispatchEndPoint
            .userReport(reportInfo: reportInfo)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func dispatchEnd(dispatchId: Int) async throws -> (success: Bool, data: DispatchEndResult?) {
        let request = DispatchEndPoint
            .dispatchEnd(dispatchId: dispatchId)
            .createRequest()
        return try await self.service.request(request)
    }
}

