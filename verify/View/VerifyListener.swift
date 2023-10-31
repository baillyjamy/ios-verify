//
//  VerifyListener.swift
//  verify
//
//  Created by Jamy Bailly on 30/07/2023.
//

import Combine

@available(iOS 15.0, *)
internal class VerifyListener {
    var onReady: (() -> Void)?
	var onFinished: (() -> Void)?
	var onMessage: ((String) -> Void)?
}
