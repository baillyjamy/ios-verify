//
//  SynapsListener.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import Foundation

@available(iOS 15.0, *)
protocol SynapsListener {
	func onReady(perform action: (() -> Void)?) -> Self
	func onFinished(perform action: (() -> Void)?) -> Self
}
