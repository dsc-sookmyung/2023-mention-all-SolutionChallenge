//
//  ViewModelProtocol.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/20.
//

import Foundation

protocol DefaultViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}


protocol AsyncOutputOnlyViewModelType {
    associatedtype Output

    func transform() async throws -> Output
}


protocol OutputOnlyViewModelType {
    associatedtype Output

    func transform() -> Output
}
