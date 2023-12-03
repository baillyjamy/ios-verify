//
//  VerifyWebView.swift
//  verify
//
//  Created by Jamy Bailly on 31/10/2023.
//

import Foundation

internal protocol VerifyDelegate {
    func onReady()
    func onFinished()
    func onMessage(_ message: String)
}
