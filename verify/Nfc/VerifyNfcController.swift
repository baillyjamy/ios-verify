//
//  VerifyNFCController.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import WebKit
import CoreNFC

@available(iOS 15.0, *)
public class VerifyNfcController: NSObject {
    private var readerSession: NFCTagReaderSession?

    private var finished: Bool = false
    private var apduContinuation: CheckedContinuation<String, Never>? = Optional.none

    private var step: String?
    private var cursor: Int = 0
    private var length: Int = -1
    private var retry: Int = 0

    private var nfcTag: NFCISO7816Tag?

    var delegate: VerifyDelegate?

    func startTagReading(tag: NFCISO7816Tag) async throws {
        self.finished = false

        DispatchQueue.main.async {
            self.sendWebviewMessage("window.__verify_ios_tag_connected()")
        }

        while true {
            let message = await waitForApduFromApi()

            if finished {
                return
            }

            let responseApdu = try await self.sendCommand(tag: tag, message)
            DispatchQueue.main.async {
                self.sendToWebviewResponseApdu(responseApdu)
            }
        }
    }

    func resetReaderSession(tag: NFCISO7816Tag) async throws -> Bool {
        if let aid = nfcTag?.initialSelectedAID {
            print("aid:")
            print(aid)
        } else {
            print("yolo")
        }

        let selectCommand = NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: 0xA4,
            p1Parameter: 0x00,
            p2Parameter: 0x00,
            data: Data(),
            expectedResponseLength: 256
        )

        let (_, sw1, sw2) = try await tag.sendCommand(apdu: selectCommand)
        if sw1 == 0x90 && sw2 == 0x00 {
            return true
        }

        if Verify.shared.debug {
            Verify.logger.error("Session reset failed. SW: \(String(format: "%02X", sw1))\(String(format: "%02X", sw2))")
        }
        return false
    }

    private func cleanupReaderSession() {
        if !finished {
            finished = true
            self.apduContinuation = Optional.none
            DispatchQueue.main.async {
                self.readerSession?.invalidate()
                self.sendWebviewMessage("window.__verify_ios_tag_disconnected()")
            }
        }
    }

    func sendRequestApduToTag(_ newApdu: String) {
        if let continuation = apduContinuation {
            continuation.resume(returning: newApdu)
        }
    }

    func waitForApduFromApi() async -> String {
        return await withCheckedContinuation { (continuation: CheckedContinuation<String, Never>) in
            apduContinuation = continuation
        }
    }

    func sendCommand(tag: NFCISO7816Tag, _ command: String) async throws -> Data {
        let cmd = Data(base64Encoded: command)!
        let apdu = NFCISO7816APDU(data: cmd)!

        var (data, sw1, sw2) = try await tag.sendCommand(apdu: apdu)
        data.append(sw1)
        data.append(sw2)
        return data
    }

    private func sendToWebviewResponseApdu(_ rapdu: Data) {
        self.sendWebviewMessage("window.__verify_ios_rapdu('\(rapdu.base64EncodedString())')")
    }

    private func sendWebviewMessage(_ cmd: String) {
        DispatchQueue.main.async {
            self.delegate?.onMessage(cmd)
        }
    }
}

@available(iOS 15.0, *)
extension VerifyNfcController: WKScriptMessageHandler {
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "verify" else {
            return
        }
        print("LOG :\(message.body)")
        if let body = message.body as? String {
            // print("LOG :\(body)")
            switch body {
            case "ready":
                delegate?.onReady()
            case "finish":
                delegate?.onFinished()
            default:
                break
            }
        } else if let body = message.body as? [String: AnyObject] {
            // print("LOG :\(body)")
            guard let type = body["type"] as? String else {
                return
            }
            switch type {
            case "nfc_start":
                nfcStart()
            case "nfc_stop":
                nfcStop()
            case "nfc_transmit":
                nfcTransmit(body: body)
            case "log":
                nfcLog(body: body)
            case "step":
                nfcStep(body: body)
            default:
                break
            }
        }
    }
}

extension VerifyNfcController: NFCTagReaderSessionDelegate {
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        if Verify.shared.debug {
            Verify.logger.info("tagReaderSessionDidBecomeActive")
        }
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if Verify.shared.debug {
            Verify.logger.error("Error while reading tag: \(error)")
        }
        cleanupReaderSession()
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        DispatchQueue.main.async {
            if tags.count > 1 {
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }

            let tag = tags.first!
            switch tag {
            case let .iso7816(tag):
                self.nfcTag = tag
            default:
                if Verify.shared.debug {
                    Verify.logger.warning("Invalid tag type")
                }
                return
            }

            Task { [nfcTag = self.nfcTag] in
                do {
                    session.connect(to: tag) { (error: Error?) in
                        if error != nil {
                            session.invalidate(errorMessage: "Connection error. Please try again.")
                            return
                        }
                    }

                    if let nfcTag {
                        if try await self.resetReaderSession(tag: nfcTag) {
                            try await self.startTagReading(tag: nfcTag)
                        }
                    }
                } catch let error {
                    if Verify.shared.debug {
                        Verify.logger.error("Error while reading session: \(error)")
                    }
                    session.invalidate(errorMessage: "Connection error. Please try again.")
                    self.cleanupReaderSession()
                }
            }
        }
    }
}

extension VerifyNfcController: VerifyNfcEvent {
    func nfcStart() {
        guard NFCNDEFReaderSession.readingAvailable else {
            if Verify.shared.debug {
                Verify.logger.error("Reading unavailable")
            }
            return
        }

        if NFCTagReaderSession.readingAvailable {
            readerSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
            readerSession?.alertMessage = "Hold your iPhone near the item to learn more about it."
            print("NFC ready ? : \(NFCTagReaderSession.readingAvailable)")
            readerSession?.begin()
        }
    }

    func nfcStop() {
        if !finished {
            finished = true
            sendRequestApduToTag("")
            readerSession?.invalidate()
        }
    }

    func nfcTransmit(body: [String: AnyObject]) {
        guard let apdu = body["apdu"] as? String else {
            return
        }
        sendRequestApduToTag(apdu)

        if readerSession?.isReady ?? false {
            if self.length > 0 {
                readerSession?.alertMessage = "\(self.step ?? "/"): \((100*self.cursor)/self.length)%";
                self.cursor += 1
            } else {
                readerSession?.alertMessage = self.step ?? "loading..."
            }
        }
    }

    func nfcStep(body: [String: AnyObject]) {
        guard let value = body["step"] as? String else { return }
        self.step = value
        guard let lengthStr = body["length"] as? String else { return }
        if let length = Int(lengthStr) {
            self.length = length
            self.cursor = 0
        } else {
            self.length = 0
        }
    }

    func nfcLog(body: [String: AnyObject]) {
        if Verify.shared.debug {
            Verify.logger.debug("\(body)")
        }
    }
}
