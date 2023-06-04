//
//  AuthEndPoint.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation

struct SignUpResult: Codable {
    let access_token: String
    let refresh_token: String
}

struct SignInResult: Codable {
    let access_token: String
    let refresh_token: String
}

struct AutoLoginResult: Codable {
    let access_token: String
    let refresh_token: String
}

struct SMSCodeResult: Codable {
    let validation_code: String
}

struct NicknameVerifyResult: Codable {}

struct LogOutResult: Codable {}
