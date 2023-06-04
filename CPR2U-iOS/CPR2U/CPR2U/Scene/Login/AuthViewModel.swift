//
//  AuthViewModel.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/06.
//

import Foundation
import Combine

enum LoginPhase {
    case PhoneNumber
    case SMSCode
    case Nickname
}

final class AuthViewModel: AuthViewModelType {
    private let authManager: AuthManager
    
    private var _phoneNumber: String?
    private var _smsCode: String?
    private var _nickname: String?
    private var _addressId: Int?
    
    var phoneNumber: String {
        get {
            guard let str = _phoneNumber else { return "" }
            return str
        }
        set(value) {
            _phoneNumber = value
        }
    }
    
    var smsCode: String {
        get {
            guard let str = _smsCode else { return "" }
            return str
        }
        set(value) {
            _smsCode = value
        }
    }
    
    var nickname: String {
        get {
            guard let str = _nickname else { return "" }
            return str
        }
        set(value) {
            _nickname = value
        }
    }
    
    var addressId: Int {
        get {
            guard let value = _addressId else { return -1 }
            return value
        }
        set(value) {
            _addressId = value
        }
    }
    
    init() {
        authManager = AuthManager(service: APIManager())
    }
    
    func autoLogin() async throws -> Bool {
        let refreshToken = UserDefaultsManager.refreshToken
        let result = Task {
            if refreshToken == "" {
                return false
            } else {
                let authResult = try await authManager.autoLogin(refreshToken: refreshToken)
                if authResult.success == true {
                    guard let data = authResult.data else { return false }
                    UserDefaultsManager.refreshToken = data.refresh_token
                    UserDefaultsManager.accessToken = data.access_token
                }
                return authResult.success
            }
        }
        return try await result.value
    }
    
    func phoneNumberVerify(phoneNumber: String) async throws -> String? {
        let taskResult = Task { () -> String? in
            var result: SMSCodeResult?
            do {
                (_, result) = try await authManager.phoneNumberVerify(phoneNumber: "+82\(phoneNumber)")
            } catch (let error) {
                print(error)
            }
            
            guard let validationCode = result?.validation_code else { return nil}
            print("인증번호 \(validationCode)")
            return validationCode
        }
        
        return await taskResult.value
    }
    
    func userVerify() async throws -> Bool {
        let result = Task { () -> Bool in
            if phoneNumber == "" {
                return false
            } else {
                let authResult = try await authManager.signIn(phoneNumber: phoneNumber, deviceToken: DeviceTokenManager.deviceToken)
                guard let data = authResult.data else { return false }
                UserDefaultsManager.accessToken = data.access_token
                UserDefaultsManager.refreshToken = data.refresh_token
                return authResult.success
            }
        }
        return try await result.value
    }
    
    func nicknameVerify(userInput: String) async throws -> NicknameStatus {
        let taskResult = Task { () -> Bool in
            let authResult = try await authManager.nicknameVerify(nickname: userInput)
            return authResult.success
        }
        
        if try await taskResult.value == true {
            return .available
        } else {
            return .unavailable
        }
    }
    
    func signUp() async throws -> Bool {
        let taskResult = Task { () -> Bool in
            if phoneNumber == "" || nickname == "" || addressId == -1 {
                return false
            } else {
                let authResult = try await authManager.signUp(nickname: nickname, phoneNumber: phoneNumber, addressId: addressId, deviceToken: DeviceTokenManager.deviceToken)
                if authResult.success == true {
                    guard let data = authResult.data else { return false }
                    UserDefaultsManager.accessToken = data.access_token
                    UserDefaultsManager.refreshToken = data.refresh_token
                    print("USER TOKEN UPDATE")
                }
                return authResult.success
            }
        }
        return try await taskResult.value
    }
    
    func getAddressList() async throws -> [AddressListResult]? {
        let taskResult = Task { () -> [AddressListResult]? in
            let authResult = try await authManager.getAddressList()
            if authResult.success == true {
                return authResult.data
            } else {
                return nil
            }
        }
        return try await taskResult.value
    }
    
    func logOut() async throws -> Bool {
        let taskResult = Task { () -> Bool in
            let authResult = try await authManager.logOut()
            return authResult.success
        }
        return try await taskResult.value
    }
    
    struct Input {
        let verifier: AnyPublisher<String?, Never>
    }

    struct Output {
        let buttonIsValid: AnyPublisher<Bool, Never>?
    }

    func transform(loginPhase: LoginPhase, input: Input) -> Output {

        let buttonStatePublisher = input.verifier.map { text in
            if let length = text?.count {
                return length > 0
            } else {
                return false
            }
        }.eraseToAnyPublisher()

        return Output(buttonIsValid: buttonStatePublisher)
    }
}
