//
//  URLs.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/11.
//

import Foundation

class URLs {
//     FOR CI:CD
//    static var baseURL: String = {
//        return ""
//    }()

    // REAL BaseURL
    static var baseURL: String = {
        guard let privatePlist = Bundle.main.url(forResource: "Private", withExtension: "plist"), let dictionary = NSDictionary(contentsOf: privatePlist), let link: String = dictionary["baseURL"] as? String else { return "" }

        return link
    }()
    
    static var mapsAPIKey: String = {
        guard let privatePlist = Bundle.main.url(forResource: "Private", withExtension: "plist"), let dictionary = NSDictionary(contentsOf: privatePlist), let link: String = dictionary["googleMapsAPIKey"] as? String else { return "" }

        return link
    }()
}
