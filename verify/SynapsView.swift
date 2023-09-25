//
//  SynapsView.swift
//  verify
//
//  Created by Jamy Bailly on 21/07/2023.
//

import SwiftUI
import WebKit
import Foundation
import Combine
import AVFoundation

@available(iOS 15.0, *)
public struct SynapsView: UIViewRepresentable {
	@ObservedObject internal var viewModel = SynapsViewModel()

	@Binding var sessionId: String
	let lang: VerifyLang
	let tierIdentifier: String?

	let delegate = SynapsWebViewDelegate()

	public init(
		sessionId: Binding<String>,
		lang: VerifyLang = .English,
		tier tierIdentifier: String? = nil
	) {
		self._sessionId = sessionId
		self.lang = lang
		self.tierIdentifier = tierIdentifier
	}

	public func makeUIView(context: Context)  -> WKWebView {
		if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
			fatalError(SynapsError.permissionDenied.localizedDescription)
		}

		let contentController = WKUserContentController();
		contentController.addUserScript(
			WKUserScript(
				source: Synaps.messageHandlerJavascript,
				injectionTime: WKUserScriptInjectionTime.atDocumentStart,
				forMainFrameOnly: false
			)
		)
		contentController.add(context.coordinator, name: "synaps")
        contentController.add(context.coordinator, name: "verify")

		let webViewConfig = WKWebViewConfiguration()
		webViewConfig.allowsInlineMediaPlayback = true
		webViewConfig.userContentController = contentController
		webViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true


		let webView = WKWebView(frame: .zero, configuration: webViewConfig)
		let request = prepareRequest()
		webView.load(request)
		webView.uiDelegate = delegate
		if #available(iOS 16.4, *) {
			webView.isInspectable = true
		}
		viewModel.onMessage = { message in
			webView.evaluateJavaScript(message)
		}
		return webView
	}

	public func updateUIView(_ webView: WKWebView, context: Context) {
	}

	func prepareRequest() -> URLRequest {
		var request = URLRequest(url: Synaps.baseUrl)
		let params = [
			"session_id": sessionId,
			"lang": lang.code,
			//"tier": tierIdentifier,
			"platform": "ios"
		]

		request.append(parameters: params)
		print(request)
		return request
	}

	public func makeCoordinator() -> SynapsCoordinator {
		SynapsCoordinator(self)
	}
}

@available(iOS 15.0, *)
extension SynapsView: SynapsListener {
	public func onReady(perform action: (() -> Void)?) -> Self {
		viewModel.onReady = action
		return self
	}

	public func onFinished(perform action: (() -> Void)?) -> SynapsView {
		viewModel.onFinished = action
		return self
	}
}
