//
//  SynapsWebViewDelegate.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import WebKit

@available(iOS 15.0, *)
public class SynapsWebViewDelegate: NSObject, WKUIDelegate {
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
