//
//  VerifyListener.swift
//
//
//  Created by Jamy Bailly on 30/07/2023.
//

import Combine

@available(iOS 15.0, *)
class VerifyListener : ObservableObject {
    var onReady: (() -> Void)? = nil
	var onFinished: (() -> Void)? = nil
	var onMessage: ((String) -> Void)? = nil
}
