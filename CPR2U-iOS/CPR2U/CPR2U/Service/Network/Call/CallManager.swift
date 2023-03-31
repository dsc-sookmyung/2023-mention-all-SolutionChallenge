//
//  CallManager.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/26.
//

import Foundation

protocol CallService {
    func getCallerList() async throws -> (success: Bool, data: CallerListInfo?)
    func callDispatcher(callerLocationInfo: CallerLocationInfo) async throws -> (success: Bool, data: CallResult?)
    func situationEnd(callId: Int) async throws -> (success: Bool, data: CallEndResult?)
    func countDispatcher(callId: Int) async throws -> (success: Bool, data: DispatcherCountResult?)
}

struct CallManager: CallService {

    private let service: Requestable
    
    init(service: Requestable) {
        self.service = service
    }
    
    func getCallerList() async throws -> (success: Bool, data: CallerListInfo?) {
        let request = CallEndPoint
            .getCallerList
            .createRequest()
        return try await self.service.request(request)
    }
    
    func callDispatcher(callerLocationInfo: CallerLocationInfo) async throws -> (success: Bool, data: CallResult?) {
        let request = CallEndPoint
            .callDispatcher(callerLocationInfo: callerLocationInfo)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func situationEnd(callId: Int) async throws -> (success: Bool, data: CallEndResult?) {
        let request = CallEndPoint
            .situationEnd(callId: callId)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func countDispatcher(callId: Int) async throws -> (success: Bool, data: DispatcherCountResult?) {
        let request = CallEndPoint
            .countDispatcher(callId: callId)
            .createRequest()
        return try await self.service.request(request)
    }
}
