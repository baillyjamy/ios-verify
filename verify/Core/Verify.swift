//
//  Verify.swift
//  verify
//
//  Created by Omar Sy on 25/05/2022.
//

import Foundation
import os

// swiftlint:disable force_unwrapping
public class Verify {
	internal static let baseEndpoint = "https://verify.synaps.io/"
    internal static let baseEndpointTest = "https://verify.dev.synaps.run"
    internal static let baseEndpointTestReset = "https://verify-git-feature-nfc-reset-synaps-hub.vercel.app"
	internal static let baseUrl = URL(string: baseEndpoint)!

	internal static let messageHandlerJavascript = """
		window.addEventListener("message", ({ data }) => {
			window.webkit.messageHandlers.verify.postMessage(data.type)
		});
	"""

    public static let shared = Verify()

    public var debug = false
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Verify.self)
    )

    internal static var translations: [String: String] = [:]
    internal static func localize(from key: String) -> String {
        guard let translation = translations[key] else {
            return key
        }
        return translation
    }
}
// swiftlint:enable force_unwrapping
