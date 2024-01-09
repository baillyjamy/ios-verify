//
//  VerifyWebViewSettings.swift
//  verify
//
//  Created by Jamy Bailly on 30/11/2023.
//

import Foundation

internal struct VerifyWebViewSettings {
    let hideClose: Bool?
    let queryItems: [URLQueryItem]?

    init(hideClose: Bool? = nil, queryItems: [URLQueryItem]? = nil) {
        self.hideClose = hideClose
        self.queryItems = queryItems
    }

    func toParameters() -> [String: String?] {
        var parameters = [
            "hideClose": hideClose.map { String($0) }
        ]
        queryItems?.forEach { item in
            parameters[item.name] = item.value
        }
        return parameters
    }
}
