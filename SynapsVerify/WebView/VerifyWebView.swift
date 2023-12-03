//
//  VerifyWebView.swift
//  verify
//
//  Created by Jamy Bailly on 29/10/2023.
//

import Foundation
import WebKit

protocol VerifyWebView: VerifyDelegate {
    var coordinator: VerifyNfcController { get }
    var listener: VerifyListener { get }
    var webViewDelegate: VerifyWKUIDelegate { get }
    func prepareRequest(sessionId: String, lang: VerifyLang, tierIdentifier: String?, settings: VerifyWebViewSettings?) -> URLRequest
}

extension VerifyWebView {
    func createWebView(frame: CGRect, sessionId: String, lang: VerifyLang, tierIdentifier: String?, settings: VerifyWebViewSettings?) -> WKWebView {
        let webView = WKWebView(frame: frame, configuration: createWebViewConfiguration())
        let request = prepareRequest(
            sessionId: sessionId,
            lang: lang,
            tierIdentifier: tierIdentifier,
            settings: settings
        )
        webView.load(request)
        webView.uiDelegate = webViewDelegate
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        listener.onMessage = { message in
            webView.evaluateJavaScript(message)
        }
        return webView
    }

    func prepareRequest(sessionId: String, lang: VerifyLang, tierIdentifier: String?, settings: VerifyWebViewSettings?) -> URLRequest {
        var request = URLRequest(url: Verify.baseUrl)
        var params: [String: String?] = [
            "session_id": sessionId,
            "lang": lang.code,
            "platform": "ios",
            "tier": tierIdentifier
        ]

        settings?.toParameters().forEach { key, value in
            if value != nil {
                params[key] = value
            }
        }

        request.append(parameters: params)
        return request
    }

    func createWebViewConfiguration() -> WKWebViewConfiguration {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.defaultWebpagePreferences.allowsContentJavaScript = true

        let contentController = WKUserContentController()
        contentController.addUserScript(
            WKUserScript(
                source: Verify.messageHandlerJavascript,
                injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                forMainFrameOnly: false
            )
        )
        contentController.add(coordinator, name: "verify")
        webViewConfig.userContentController = contentController
        return webViewConfig
    }

    internal func onReady() {
        listener.onReady?()
    }

    internal func onFinished() {
        listener.onFinished?()
    }

    internal func onMessage(_ message: String) {
        listener.onMessage?(message)
    }
}
