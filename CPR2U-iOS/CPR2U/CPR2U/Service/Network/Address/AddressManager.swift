//
//  AddressManager.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/29.
//

import Foundation

protocol AddressService {
    func setUserAddress(id: Int) async throws -> (success: Bool, data: SetUserAddressResult?)
}

struct AddressManager: AddressService {
    
    private let service: Requestable
    
    init(service: Requestable) {
        self.service = service
    }
    
    func setUserAddress(id: Int) async throws -> (success: Bool, data: SetUserAddressResult?) {
        let request = AddressEndPoint
            .setUserAddress(id: id)
            .createRequest()
        return try await self.service.request(request)
    }
}
    
