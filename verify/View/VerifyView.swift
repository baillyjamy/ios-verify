//
//  VerifyView.swift
//  verify
//
//  Created by Jamy Bailly on 21/07/2023.
//

import SwiftUI
import WebKit
import AVFoundation

@available(iOS 15.0, *)
public struct VerifyView: UIViewRepresentable, VerifyWebView {
	@Binding var sessionId: String
	let lang: VerifyLang
	let tierIdentifier: String?

    let coordinator = VerifyNfcController()
	let webViewDelegate = VerifyWKUIDelegate()
    internal var listener = VerifyListener()

	public init(
		sessionId: Binding<String>,
		lang: VerifyLang = .english,
		tier tierIdentifier: String? = nil
	) {
		self._sessionId = sessionId
		self.lang = lang
		self.tierIdentifier = tierIdentifier
	}

	public func makeUIView(context: Context) -> WKWebView {
		if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
			fatalError(VerifyError.permissionDenied.localizedDescription)
		}
        coordinator.delegate = self
        let webView = createWebView(frame: .zero, sessionId: sessionId, lang: lang, tierIdentifier: tierIdentifier)
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
