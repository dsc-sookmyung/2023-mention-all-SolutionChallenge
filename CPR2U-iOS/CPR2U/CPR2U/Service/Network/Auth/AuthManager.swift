//
//  AuthManager.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation

protocol AuthService {
    func phoneNumberVerify(phoneNumber: String) async throws -> (success: Bool, data: SMSCodeResult?)
    func nicknameVerify(nickname: String) async throws -> (success: Bool, data: NicknameVerifyResult?)
    func signIn(phoneNumber: String, deviceToken: String) async throws -> (success: Bool, data: SignInResult?)
    func signUp(nickname: String, phoneNumber: String, addressId: Int, deviceToken: String) async throws -> (success: Bool, data: SignUpResult?)
    func autoLogin(refreshToken: String) async throws -> (success: Bool, data: AutoLoginResult?)
    func logOut() async throws -> (success: Bool, data: LogOutResult?)
    func getAddressList() async throws -> (success: Bool, data: [AddressListResult]?)
}

struct AuthManager: AuthService {
    
    private let service: Requestable
    
    init(service: Requestable) {
        self.service = service
    }
    
    func phoneNumberVerify(phoneNumber: String) async throws -> (success: Bool, data: SMSCodeResult?) {
        let request = AuthEndPoint
            .phoneNumberVerify(phoneNumber: phoneNumber)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func nicknameVerify(nickname: String) async throws -> (success: Bool, data: NicknameVerifyResult?) {
        let request = AuthEndPoint
            .nicknameVerify(nickname: nickname)
            .createRequest()
        return try await self.service.request(request)
        }
    
    func signIn(phoneNumber: String, deviceToken: String) async throws -> (success: Bool, data: SignInResult?) {
        let request = AuthEndPoint
            .signIn(phoneNumber: phoneNumber, deviceToken: deviceToken)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func signUp(nickname: String, phoneNumber: String, addressId: Int, deviceToken: String) async throws -> (success: Bool, data: SignUpResult?) {
        let request = AuthEndPoint
            .signUp(nickname: nickname, phoneNumber: phoneNumber, addressId: addressId, deviceToken: deviceToken)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func autoLogin(refreshToken: String) async throws -> (success: Bool, data: AutoLoginResult?) {
        let request = AuthEndPoint
            .autoLogin(refreshToken: refreshToken)
            .createRequest()
        return try await self.service.request(request)
    }
    
    func getAddressList() async throws -> (success: Bool, data: [AddressListResult]?) {
        let request = AuthEndPoint
            .getAddressList
            .createRequest()
        return try await self.service.request(request)
    }
    
    func logOut() async throws -> (success: Bool, data: LogOutResult?) {
        let request = AuthEndPoint
            .logOut
            .createRequest()
        return try await self.service.request(request)
    }
}
