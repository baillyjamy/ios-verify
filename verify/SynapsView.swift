//
//  SynapsView.swift
//  verify
//
//  Created by Jamy Bailly on 21/07/2023.
//

#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(WebKit)
import WebKit
#endif
import Foundation
import Combine
import AVFoundation

@available(iOS 15.0, *)
public class Delegate: NSObject, WKUIDelegate {
	public func webView(
		_ webView: WKWebView,
		requestMediaCapturePermissionFor origin: WKSecurityOrigin,
		initiatedByFrame frame: WKFrameInfo,
		type: WKMediaCaptureType,
		decisionHandler: @escaping (WKPermissionDecision) -> Void
	) {
		decisionHandler(.grant)
	}
}

#if canImport(SwiftUI) && canImport(WebKit)
@available(iOS 15.0, *)
public struct SynapsView: UIViewRepresentable {
	@ObservedObject private var viewModel = ViewModel()
	@Binding var sessionId: String
	let lang: VerifyLang
	let tierIdentifier: String?

	let delegate = Delegate()


	public init(
		sessionId: Binding<String>,
		lang: VerifyLang = .English,
		tier tierIdentifier: String? = nil
	) {
		self._sessionId = sessionId
		self.lang = lang
		self.tierIdentifier = tierIdentifier
	}

	public func makeUIView(context: Context) -> WKWebView {
		let contentController = WKUserContentController();
		contentController.addUserScript(WKUserScript(source: """
			window.addEventListener("message", ({ data }) => {
				window.webkit.messageHandlers.synaps.postMessage(data.type)
			});
		""", injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false))
		contentController.add(ScriptHandler(viewModel: viewModel), name: "synaps")
		let webViewConfig = WKWebViewConfiguration()
		webViewConfig.allowsInlineMediaPlayback = true
		webViewConfig.userContentController = contentController
		webViewConfig.preferences.javaScriptEnabled = true


		let webView = WKWebView(frame: .zero, configuration: webViewConfig)
		let request = prepareRequest()
		webView.load(request)
		setSubscriber(webView)
		webView.uiDelegate = delegate
		if #available(iOS 16.4, *) {
			webView.isInspectable = true
		} else {
			// Fallback on earlier versions
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
			"tier": tierIdentifier,
			"mobile": "ios"
		]

		request.append(parameters: params)
		print(request)
		return request
	}

	func setSubscriber(_ webView: WKWebView) {
		print("setSubscriber")
		viewModel.$permissionGranted.sink { isGranted in
			if (isGranted) {
				print("fffff")
				webView.evaluateJavaScript("window.__verify_ios_camera_permission(\(isGranted))")
			}
		}.store(in: &viewModel.anyCancellables)
	}
}

extension URLRequest {
	mutating func append(parameters: [String: String?]) {
		guard let url = url, var urlComponents = URLComponents(string: url.absoluteString) else {
			return
		}

		urlComponents.queryItems = parameters.map { key, value in
			URLQueryItem(name: key, value: value)
		}
		self.url = urlComponents.url
	}
}

@available(iOS 15.0, *)
public struct SynapsViewOld: UIViewRepresentable {
	@Binding var sessionId: String
	var tier: String?
	var type: String
	var lang: String?
	var primaryColor: UIColor?
	var secondaryColor: UIColor?
	var ready: () -> Void
	var finished: () -> Void

	public init(sessionId: Binding<String>, type:String="individual", tier: String?=nil, lang: String?=nil, primaryColor: UIColor?=nil, secondaryColor: UIColor?=nil, ready: @escaping () -> Void , finished: @escaping () -> Void){
		self._sessionId = sessionId
		self.type = type
		self.tier = tier
		self.primaryColor = primaryColor
		self.secondaryColor = secondaryColor
		self.lang = lang
		self.finished = finished
		self.ready = ready
	}

	public func makeUIView(context: Context) -> UISynaps  {
		let webView = UISynaps(frame: .zero, scriptHandler: StoryBoardHandler(self), type: self.type, tier: self.tier, lang: self.lang, primaryColor: self.primaryColor, secondaryColor: self.secondaryColor)

		return webView
	}

	public func updateUIView(_ uiView: UISynaps, context: Context) {
		AVCaptureDevice.requestAccess(
			for: .video,
			completionHandler: { accessGranted in
				DispatchQueue.main.async {
					//self.permissionGranted = accessGranted
					//print("PERMISSION GRANTED: \(self.permissionGranted)")
				}
			}
		)

		if self.sessionId != ""  {
			uiView.setSessionId(sessionId: self.sessionId)
		}
	}
	
	public class StoryBoardHandler: NSObject, WKScriptMessageHandler {
		var view: SynapsViewOld
		init(_ view: SynapsViewOld) {
			self.view = view
			super.init()
		}
		public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
			if message.name == "synaps" {
				let status = message.body as! String
				if status == "ready" {
					self.view.ready()
				} else if status == "finished" {
					self.view.finished()
				}
			}
		  }
	}
}

@available(iOS 15.0, *)
public class ScriptHandler: NSObject, WKScriptMessageHandler {
	let viewModel: SynapsView.ViewModel
	
	internal init(viewModel: SynapsView.ViewModel) {
		self.viewModel = viewModel
	}
	
	@MainActor public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if message.name == "synaps" {
			dump(message)
			print("Synaps Log: \(message.body)")
			if (message.body as? String == "request_camera_permission") {
				viewModel.requestPermission()
			}
		}
		if message.name == "logHandler" {
			print("LOG: \(message.body)")
		}

		print("BULK LOG: \(message.body)")
	}
}
#endif
