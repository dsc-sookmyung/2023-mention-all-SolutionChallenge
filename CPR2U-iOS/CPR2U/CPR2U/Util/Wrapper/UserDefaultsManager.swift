//
//  UserDefaultsManager.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/21.
//

import Foundation

@propertyWrapper
fileprivate struct UserDefaultWrapper<E> {
    private let key: String
    private let defaultValue: E

    init(key: String, defaultValue: E) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: E {
        get {
            return UserDefaults.standard.object(forKey: key) as? E ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct UserDefaultsManager {
    @UserDefaultWrapper(key: "accessToken", defaultValue: "")
    static var accessToken
    
    @UserDefaultWrapper(key: "refreshToken", defaultValue: "")
    static var refreshToken
    
    @UserDefaultWrapper(key: "isCertificateNotice", defaultValue: false)
    static var isCertificateNotice
    
    @UserDefaultWrapper(key: "isAddressSet", defaultValue: false)
    static var isAddressSet
}
