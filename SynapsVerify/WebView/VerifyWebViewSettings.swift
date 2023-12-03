//
//  VerifyWebViewSettings.swift
//  verify
//
//  Created by Jamy Bailly on 30/11/2023.
//

import Foundation

internal struct VerifyWebViewSettings {
    let hideClose: Bool?

    func toParameters() -> [String: String?] {
        return [
            "hideClose": hideClose.map { String($0) }
        ]
    }
}
