//
//  Synaps.swift
//  verify
//
//  Created by Omar Sy on 25/05/2022.
//

import Foundation

internal class Synaps {
	static let baseEndpoint = "https://verify.synaps.io/"
	static let baseDevEndpoint = "https://verify-git-riwan-nfc-synaps-hub.vercel.app"
	static let baseDevEndpointRaphael = "https://verify-git-raphael-nfc-synaps-hub.vercel.app"
	static let baseUrl = URL(string: baseDevEndpointRaphael)!

	static let messageHandlerJavascript = """
		window.addEventListener("message", ({ data }) => {
			window.webkit.messageHandlers.synaps.postMessage(data.type)
		});
	"""
}

public enum VerifyLang {
	case English
	case French
	case German
	case Spanish
	case Italian
	case Japanese
	case Korean
	case Portuguese
	case Romanian
	case Russian
	case Turkish
	case Vietnamese
	case Chinese
	case ChineseTraditional

	var code: String {
		switch self {
		case .English:
			return "en"
		case .French:
			return "fr"
		case .German:
			return "de"
		case .Spanish:
			return "es"
		case .Italian:
			return "it"
		case .Japanese:
			return "ja"
		case .Korean:
			return "ko"
		case .Portuguese:
			return "pt"
		case .Romanian:
			return "ro"
		case .Russian:
			return "ru"
		case .Turkish:
			return "tr"
		case .Vietnamese:
			return "vi"
		case .Chinese:
			return "zh-CN"
		case .ChineseTraditional:
			return "zh-TW"
		}
	}
}
