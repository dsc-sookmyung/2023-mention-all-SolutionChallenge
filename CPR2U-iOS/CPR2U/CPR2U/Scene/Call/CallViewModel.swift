//
//  CallViewModel.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/26.
//

import Combine
import Foundation
import GoogleMaps

final class CallViewModel: OutputOnlyViewModelType {
    @Published private(set)var callerListInfo: CallerListInfo?
    @Published private(set)var dispatcherCount: Int?
    
    private var callManager: CallManager
    private var dispatchManager: DispatchManager
    
    private var mapManager: MapManager
    private var currentLocation: CLLocationCoordinate2D?
    
    private var currentLocationAddress = CurrentValueSubject<String, Never>("Unable")
    
    private var callId: Int?
    private let iscalled = CurrentValueSubject<Bool, Never>(false)
    private let isDispatchEnd = CurrentValueSubject<Bool, Never>(false)
    
    var timer: Timer.TimerPublisher?
    
    init() {
        callManager = CallManager(service: APIManager())
        mapManager = MapManager()
        dispatchManager = DispatchManager(service: APIManager())
        receiveCallerList()
        setLocation()
    }
    
    struct Output {
        let isCalled: CurrentValueSubject<Bool, Never>
        let currentLocationAddress: CurrentValueSubject<String, Never>?
    }
    
    func transform() -> Output {
        return Output(isCalled: iscalled, currentLocationAddress: currentLocationAddress)
    }
    
    func isCallSucceed() {
        iscalled.send(true)
    }
    
    func cancelTimer() {
        timer?.connect().cancel()
    }
    
    func setLocation() {
        currentLocation = mapManager.setLocation()
    }
    
    func getLocation() -> CLLocationCoordinate2D {
        setLocation()
        guard let currentLocation = currentLocation else { return CLLocationCoordinate2D(latitude: 15, longitude: 15) }
        return currentLocation
    }

    func setLocationAddress(str: String) {
        currentLocationAddress.send(str)
    }
    
    func receiveCallerList() {
        Task {
            let callResult = try await callManager.getCallerList()
            
            guard let list = callResult.data else { return }
            callerListInfo = list
        }
    }
    
    func callDispatcher() async throws {
        Task {
            let address = self.currentLocationAddress.value
            let callerLocationInfo = CallerLocationInfo(latitude: getLocation().latitude, longitude: getLocation().longitude, full_address: address )
            let callResult = try await callManager.callDispatcher(callerLocationInfo: callerLocationInfo)
            guard let data = callResult.data else { return }
            updateCallId(callId: data.call_id)
        }
    }
    
    func situationEnd() async throws {
        guard let callId = callId else { return }
        
        Task {
            try await callManager.situationEnd(callId: callId)
        }
    }
    
    func countDispatcher() {
        guard let callId = callId else { return }
        
        Task {
            let callResult = try await callManager.countDispatcher(callId: callId)
            dispatcherCount = callResult.data?.number_of_angels
        }
    }
    
    private func updateCallId(callId: Int) {
        self.callId = callId
    }
    
    func dispatchEnd(dispatchId: Int) async throws -> Bool {
        let taskResult = Task { () -> Bool in
            let result = try await dispatchManager.dispatchEnd(dispatchId: dispatchId)
            return result.success
        }
        return try await taskResult.value
    }
    
    func updateDispatchEnd() {
        isDispatchEnd.send(true)
        
    }
    
    func getDispatchEnd() -> CurrentValueSubject<Bool, Never> {
        return isDispatchEnd
    }
    func dispatchAccept(cprCallId: Int) async throws -> (Bool, DispatchInfo?) {
        let taskResult = Task { () -> (Bool, DispatchInfo?)  in
            let result = try await dispatchManager.dispatchAccept(cprCallId: cprCallId)
            return (result.success, result.data)
        }
        return try await taskResult.value
    }
    func userReport(reportInfo: ReportInfo) async throws -> Bool {
        let taskResult = Task { () -> Bool in
            let result = try await dispatchManager.userReport(reportInfo: reportInfo)
            return result.success
        }
        return try await taskResult.value
    }
}
