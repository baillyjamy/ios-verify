//
//  SynapsScriptHandler.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import WebKit

@available(iOS 15.0, *)
public class ScriptHandler: NSObject, WKScriptMessageHandler {
	let viewModel: SynapsViewModel

	internal init(viewModel: SynapsViewModel) {
		self.viewModel = viewModel
	}

	@MainActor public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if message.name == "synaps" {
			switch message.body as? String {
			case "ready":
				viewModel.onReady?()
			case "finished":
				viewModel.onFinished?()
			default:
				break
			}
			if (message.body as? String == "ready") {
				viewModel.ready = true
			}
		}
	}
}
