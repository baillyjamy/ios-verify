//
//  VerifyNfcEvent.swift
//  verify
//
//  Created by Jamy Bailly on 31/10/2023.
//

import Foundation

protocol VerifyNfcEvent {
    func nfcStart()
    func nfcStop(body: [String: AnyObject])
    func nfcTransmit(body: [String: AnyObject]) async throws
    func nfcStep(body: [String: AnyObject])
    func nfcLog(body: [String: AnyObject])
    func localize(body: [String: AnyObject])
}
