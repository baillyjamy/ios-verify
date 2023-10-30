//
//  SynapsView.swift
//  verify
//
//  Created by Jamy Bailly on 21/07/2023.
//

import SwiftUI
import WebKit
import AVFoundation

@available(iOS 15.0, *)
public struct SynapsView: UIViewRepresentable, VerifyWebView {
	@Binding var sessionId: String
	let lang: VerifyLang
	let tierIdentifier: String?

    let coordinator = SynapsCoordinator()
	let webViewDelegate = VerifyWebViewDelegate()
    internal var viewModel = SynapsViewModel()

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
        self.viewModel.onReady = action
        return self
    }

    public func onFinished(perform action: (() -> Void)?) -> Self {
        self.viewModel.onFinished = action
        return self
    }
}
