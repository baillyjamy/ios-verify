//
//  Verify.swift
//  verify
//
//  Created by Omar Sy on 25/05/2022.
//

import Foundation
import os

public class Verify {
	internal static let baseEndpoint = "https://verify.synaps.io/"
    internal static let baseEndpointTest = "https://verify.dev.synaps.run"
	internal static let baseUrl = URL(string: baseEndpointTest)!

	internal static let messageHandlerJavascript = """
		window.addEventListener("message", ({ data }) => {
			window.webkit.messageHandlers.verify.postMessage(data.type)
		});
	"""

    public static let shared = Verify()

    public var debug: Bool = false
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Verify.self)
    )
}
