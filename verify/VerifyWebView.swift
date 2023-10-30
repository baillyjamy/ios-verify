//
//  VerifyWebView.swift
//  verify
//
//  Created by Jamy Bailly on 29/10/2023.
//

import Foundation
import WebKit

internal protocol VerifyDelegate {
    func onReady()
    func onFinished()
    func onMessage(_ message: String)
}

protocol VerifyWebView: VerifyDelegate {
    var coordinator: SynapsCoordinator { get }
    var viewModel: SynapsViewModel { get }
    var webViewDelegate: SynapsWebViewDelegate { get }
    func prepareRequest(sessionId: String, lang: VerifyLang) -> URLRequest
}

extension VerifyWebView {
    func createWebView(frame: CGRect, sessionId: String, lang: VerifyLang) -> WKWebView {
        let webView = WKWebView(frame: frame, configuration: createWebViewConfiguration())
        let request = prepareRequest(sessionId: sessionId, lang: lang)
        webView.load(request)
        webView.uiDelegate = webViewDelegate
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        viewModel.onMessage = { message in
            webView.evaluateJavaScript(message)
        }
        return webView
    }

    func prepareRequest(sessionId: String, lang: VerifyLang) -> URLRequest {
        var request = URLRequest(url: Synaps.baseUrl)
        let params = [
            "session_id": sessionId,
            "lang": lang.code,
            "platform": "ios"
        ]

        request.append(parameters: params)
        return request
    }

    func createWebViewConfiguration() -> WKWebViewConfiguration {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true

        let contentController = WKUserContentController();
        contentController.addUserScript(
            WKUserScript(
                source: Synaps.messageHandlerJavascript,
                injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                forMainFrameOnly: false
            )
        )
        contentController.add(coordinator, name: "verify")
        webViewConfig.userContentController = contentController
        return webViewConfig
    }

    internal func onReady() {
        viewModel.onReady?()
    }

    internal func onFinished() {
        viewModel.onFinished?()
    }

    internal func onMessage(_ message: String) {
        viewModel.onMessage?(message)
    }
}
