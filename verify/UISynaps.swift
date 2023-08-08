//
//  CustomWebView.swift
//  pocveriyiosstoryboard
//
//  Created by Omar Sy on 30/05/2022.
//

import Foundation
import WebKit

public class CustomScript: NSObject, WKScriptMessageHandler {
    var view: UISynaps!
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "synaps" {
            self.view.status = message.body as? String
            self.view.sendActions(for: .valueChanged)
          // make native calls to the WebRTC framework here
        }
      }
}

extension URL {

    mutating func appendQueryItem(name: String, value: String?) {

        guard var urlComponents = URLComponents(string: absoluteString) else { return }

        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        let queryItem = URLQueryItem(name: name, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        self = urlComponents.url!
    }
}

extension UIColor {

    var toHex: String? {
        return toHex()
    }

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}
@objcMembers public class UISynaps:  UIControl {
	open var baseUrl = Synaps.baseUrl
    var synaps: WKWebView!
    public var status: String!
    var scriptHandler: WKScriptMessageHandler!

    @IBInspectable
    public var primaryColor: UIColor? {
            didSet { redraw() }
        }

    @IBInspectable
    public var secondaryColor: UIColor? {
            didSet { redraw() }
        }

    @IBInspectable
    public var tier: String? {
            didSet { redraw() }
        }

    @objc public var sessionId: String? {
            didSet { redraw() }
    }

    @IBInspectable
    public var lang: String? {
            didSet { redraw() }
    }

    public init(frame: CGRect, scriptHandler: WKScriptMessageHandler, type: String="individual", tier: String?=nil, lang: String?=nil, primaryColor: UIColor?=nil, secondaryColor: UIColor?=nil){
        super.init(frame: frame)
        self.tier = tier
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.lang = lang
        self.scriptHandler = scriptHandler
        self.initWebView()
    }

    public init(frame: CGRect, scriptHandler: WKScriptMessageHandler, type: String="individual") {
        super.init(frame: frame)
        self.scriptHandler = scriptHandler
    }

	public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public init?(coder: NSCoder, scriptHandler: WKScriptMessageHandler, type: String="individual"){
        super.init(coder: coder)
        self.scriptHandler = scriptHandler
        self.initWebView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func initWebView() {
        let contentController = WKUserContentController();
        contentController.addUserScript(WKUserScript(source: """
            window.addEventListener("message", ({ data }) => {
                if(data.type === "ready" || data.type === "finish"){
                    window.webkit.messageHandlers.synaps.postMessage(data.type)
                }
            });
        """, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false))
        contentController.add(self.scriptHandler, name: "synaps")
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.userContentController = contentController
        self.synaps = WKWebView(frame: self.frame, configuration: webViewConfig)
        self.addSubview(self.synaps)
        self.synaps.translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: self.synaps.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: self.synaps.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: self.synaps.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: self.synaps.trailingAnchor).isActive = true
    }
    public func redraw(){
		var url = baseUrl
        let params = [
            "session_id": self.sessionId,
            "tier": self.tier,
            "lang": self.lang,
            "primary_color": self.primaryColor?.toHex,
            "secondary": self.secondaryColor?.toHex
            
        ]
        for (key, val) in params {
            if val != nil {
               url.appendQueryItem(name: key, value: val)
            }
        }
        if (url != nil) && (self.sessionId != nil) {
            self.synaps.load(URLRequest(url: url))
        }
    }
    public func setSessionId(sessionId: String){
        self.sessionId = sessionId
    }
}

@objcMembers public class UISynapsIndividual: UISynaps {
    public  override init(frame: CGRect){
        let sh =  CustomScript()
        super.init(frame: frame, scriptHandler: sh)
        sh.view = self
    }
    public  required init?(coder: NSCoder){
        let sh =  CustomScript()
        super.init(coder: coder, scriptHandler: sh)
        sh.view = self
    }
}

@objcMembers public class UISynapsCorporate: UISynaps {
    public override init(frame: CGRect){
        let sh =  CustomScript()
        super.init(frame: frame, scriptHandler: sh, type: "corporate")
        sh.view = self
    }
    public required init?(coder: NSCoder){
        let sh =  CustomScript()
        super.init(coder: coder, scriptHandler: sh, type: "corporate")
        sh.view = self
    }
}
