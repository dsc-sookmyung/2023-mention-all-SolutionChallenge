//
//  Encodable+.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/12.
//

import Foundation

extension Encodable {
    func encode() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            return nil
        }
    }
}
