//
//  VerifyUiView.swift
//  verify
//
//  Created by Jamy Bailly on 15/10/2023.
//

import UIKit
import WebKit
import AVFoundation

@available(iOS 15.0, *)
public class VerifyUiView: UIView, VerifyWebView {
    var webView: WKWebView!
    let coordinator = SynapsCoordinator()
    let webViewDelegate = SynapsWebViewDelegate()
    internal var viewModel = SynapsViewModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }

    public func startSession(sessionId: String, lang: VerifyLang) {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            fatalError(VerifyError.permissionDenied.localizedDescription)
        }
        coordinator.delegate = self
        webView = createWebView(frame: self.frame, sessionId: sessionId, lang: lang)
        self.addSubview(webView)
        setConstraints()
    }

    private func setConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }

    public func onReady(perform action: (() -> Void)?) {
        self.viewModel.onReady = action
    }

    public func onFinished(perform action: (() -> Void)?) {
        self.viewModel.onFinished = action
    }
}
