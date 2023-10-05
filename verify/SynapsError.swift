//
//  SynapsError.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import Foundation

enum SynapsError: Error {
	case permissionDenied
}

extension SynapsError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .permissionDenied:
			return NSLocalizedString("The AVMediaType .video permission has not been authorized. Please implement the permission request with error handling to avoid initializing the component in case of refusal.", comment: "AVMediaType .video permission error")
		}
	}
}
