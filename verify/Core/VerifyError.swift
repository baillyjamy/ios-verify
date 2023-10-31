//
//  VerifyError.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import Foundation

enum VerifyError: Error {
    case permissionDenied
    case missingSessionId
}

// swiftlint:disable line_length
extension VerifyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString(
                "The AVMediaType .video permission has not been authorized. Please implement the permission request with error handling to avoid initializing the component in case of refusal.",
                comment: "AVMediaType .video permission error"
            )
        case .missingSessionId:
            return NSLocalizedString(
                "The session id is empty or missing. To initialize the view, specify the session id before displaying the view.",
                comment: "Session id missing"
            )
        }
    }
}
// swiftlint:enable line_length
