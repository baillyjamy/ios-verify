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
    let coordinator = VerifyNfcController()
    let webViewDelegate = VerifyWKUIDelegate()
    internal var listener = VerifyListener()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func startSession(sessionId: String, lang: VerifyLang = .english, tier tierIdentifier: String? = nil) {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            if Verify.shared.debug {
                Verify.logger.warning("\(VerifyError.permissionDenied.localizedDescription)")
            }
        }
        coordinator.delegate = self
        webView = createWebView(frame: self.frame, sessionId: sessionId, lang: lang, tierIdentifier: tierIdentifier)
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
        self.listener.onReady = action
    }

    public func onFinished(perform action: (() -> Void)?) {
        self.listener.onFinished = action
    }
}
