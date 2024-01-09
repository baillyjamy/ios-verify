//
//  VerifyView.swift
//  verify
//
//  Created by Jamy Bailly on 21/07/2023.
//

import SwiftUI
import WebKit
import AVFoundation
import os

@available(iOS 15.0, *)
public struct VerifyView: UIViewRepresentable, VerifyWebView {
	let sessionId: String
	let lang: VerifyLang
	let tierIdentifier: String?
    let settings: VerifyWebViewSettings?

    let coordinator = VerifyNfcController()
	let webViewDelegate = VerifyWKUIDelegate()
    internal var listener = VerifyListener()

	public init(
		sessionId: String,
		lang: VerifyLang = .english,
		tier tierIdentifier: String? = nil
	) {
        self.sessionId = sessionId
		self.lang = lang
		self.tierIdentifier = tierIdentifier
        self.settings = nil
	}

    public init(
        sessionId: String,
        lang: VerifyLang = .english,
        tier tierIdentifier: String? = nil,
        hideClose: Bool = false
    ) {
        self.sessionId = sessionId
        self.lang = lang
        self.tierIdentifier = tierIdentifier
        self.settings = VerifyWebViewSettings(hideClose: hideClose)
    }

    public init(
        sessionId: String,
        lang: VerifyLang = .english,
        tier tierIdentifier: String? = nil,
        queryItems: [URLQueryItem]
    ) {
        self.sessionId = sessionId
        self.lang = lang
        self.tierIdentifier = tierIdentifier
        self.settings = VerifyWebViewSettings(queryItems: queryItems)
    }


	public func makeUIView(context: Context) -> WKWebView {
		if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            if Verify.shared.debug {
                Verify.logger.warning("\(VerifyError.permissionDenied.localizedDescription)")
            }
		}
        coordinator.delegate = self
        let webView = createWebView(
            frame: .zero,
            sessionId: sessionId,
            lang: lang,
            tierIdentifier: tierIdentifier,
            settings: settings
        )
		return webView
	}

	public func updateUIView(_ webView: WKWebView, context: Context) {
	}

    public func onReady(perform action: (() -> Void)?) -> Self {
        self.listener.onReady = action
        return self
    }

    public func onFinished(perform action: (() -> Void)?) -> Self {
        self.listener.onFinished = action
        return self
    }
}
