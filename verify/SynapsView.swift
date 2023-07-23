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

#if canImport(SwiftUI) && canImport(WebKit)
@available(iOS 13.0, *)
public struct SynapsViewNew: UIViewRepresentable {
	@Binding var sessionId: String
	let type: VerifyType

	public init(
		sessionId: Binding<String>,
		type: VerifyType
	) {
		self._sessionId = sessionId
		self.type = type
	}

	public func makeUIView(context: Context) -> WKWebView {
		return WKWebView()
	}

	public func updateUIView(_ webView: WKWebView, context: Context) {
		let request = prepareRequest()
		webView.load(request)
	}

	func prepareRequest() -> URLRequest {
		var request = URLRequest(url: type.url)
		let params = [
			"session_id": sessionId
		]
		request.httpBody = params.getPostString().data(using: .utf8)
		return request
	}
}

extension Dictionary where Key == String, Value == String {
	func getPostString() -> String {
		var data = [String]()
		for(key, value) in self {
			data.append(key + "=\(value)")
		}
		return data.map { String($0) }.joined(separator: "&")
	}
}



@available(iOS 13.0, *)
public struct SynapsView: UIViewRepresentable {
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

		if self.sessionId != ""  {
			uiView.setSessionId(sessionId: self.sessionId)
		}
	}
	
	public class StoryBoardHandler: NSObject, WKScriptMessageHandler {
		var view: SynapsView
		init(_ view: SynapsView) {
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
#endif
