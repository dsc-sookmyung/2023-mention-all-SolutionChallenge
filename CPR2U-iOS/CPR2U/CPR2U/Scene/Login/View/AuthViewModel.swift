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

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(loginPhase: LoginPhase, input: Input) -> Output
}

final class AuthViewModel: ViewModelType {

    private let authManager: AuthManager
    private var phoneNumberString: String?
    private var smsCode: String?
    private var nickname: String?
    
    init() {
        authManager = AuthManager(service: APIManager())
    }
    
    func getPhoneNumber() -> String {
        guard let str = phoneNumberString else { return "" }
        return "+82 \(str)"
    }
    
    func getSMSCode() -> String {
        guard let str = smsCode else { return "" }
        return str
    }
    
    func getNickname() -> String {
        guard let str = nickname else { return "" }
        return str
    }
    
    func setPhoneNumber(number: String) {
        phoneNumberString = number
    }
    
    func setSMSCode(number: String) {
        smsCode = number
    }
    
    func setNickname(name: String) {
        nickname = name
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
                (_, result) = try await authManager.phoneNumberVerify(phoneNumber: phoneNumber)
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
            guard let phoneNumber = phoneNumberString else { return false }
            let authResult = try await authManager.signIn(phoneNumber: phoneNumber, deviceToken: DeviceTokenManager.deviceToken)
            
            return authResult.success
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
            guard let phoneNumber = phoneNumberString, let nickname = nickname else { return false }
            let authResult = try await authManager.signUp(nickname: nickname, phoneNumber: phoneNumber, deviceToken: DeviceTokenManager.deviceToken)
            if authResult.success == true {
                guard let data = authResult.data else { return false }
                UserDefaultsManager.accessToken = data.access_token
                UserDefaultsManager.refreshToken = data.refresh_token
                print("USER TOKEN UPDATE")
            }
            return authResult.success
        }
        return try await taskResult.value
    }
    
    struct Input {
        let verifier: AnyPublisher<String, Never>
    }

    struct Output {
        let buttonIsValid: AnyPublisher<Bool, Never>
    }

    func transform(loginPhase: LoginPhase, input: Input) -> Output {
        let buttonStatePublisher = input.verifier.map { verifier in
            verifier.count > 0
        }.eraseToAnyPublisher()
        return Output(buttonIsValid: buttonStatePublisher)
    }
}
