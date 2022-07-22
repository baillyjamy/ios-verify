//
//  Synaps.swift
//  verify
//
//  Created by Omar Sy on 25/05/2022.
//

#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(WebKit)
import WebKit
#endif
import AVFoundation

#if canImport(SwiftUI) && canImport(WebKit)
@available(iOS 13.0, *)
public struct Synaps: UIViewRepresentable {
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
        var view: Synaps
        init(_ view: Synaps) {
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
