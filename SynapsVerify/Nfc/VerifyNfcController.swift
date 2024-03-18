//
//  VerifyNFCController.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import WebKit
import CoreNFC
import AVFoundation

@available(iOS 15.0, *)
internal class VerifyNfcController: NSObject {
    private var readerSession: NFCTagReaderSession?

    private var step: String?
    private var isProgress = false

    private var nfcTag: NFCISO7816Tag?
    private let retryInterval = DispatchTimeInterval.milliseconds(500)

    var delegate: VerifyDelegate?

    func startTagReading() {
        self.sendWebviewMessage("window.__verify_ios_tag_connected()")
    }

    func resetReaderSession(tag: NFCISO7816Tag) async throws -> Bool {
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

    func sendCommand(tag: NFCISO7816Tag, command: String) async throws -> Data {
        guard let cmd = Data(base64Encoded: command) else {
            throw VerifyError.commandFailed
        }
        guard let apdu = NFCISO7816APDU(data: cmd) else {
            throw VerifyError.commandFailed
        }

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
    internal func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "verify" else {
            return
        }
        if let body = message.body as? String {
            switch body {
            case "ready":
                delegate?.onReady()
            case "finish":
                delegate?.onFinished()
            default:
                break
            }
        } else if let body = message.body as? [String: AnyObject] {
            Task { [body] in
                guard let type = body["type"] as? String else {
                    return
                }
                switch type {
                case "nfc_start":
                    nfcStart()
                case "nfc_stop":
                    nfcStop(body: body)
                case "nfc_transmit":
                    await nfcTransmit(body: body)
                case "log":
                    nfcLog(body: body)
                case "step":
                    nfcStep(body: body)
                case "localize":
                    localize(body: body)
                case "request_camera_permission":
                    cameraRequestPermission(body: body)
                default:
                    break
                }
            }
        }
    }
}

extension VerifyNfcController: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        if Verify.shared.debug {
            Verify.logger.info("tagReaderSessionDidBecomeActive")
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if Verify.shared.debug {
            Verify.logger.error("Error while reading tag: \(error)")
        }
        session.alertMessage = error.localizedDescription
        if let readerError = error as? NFCReaderError,
            readerError.code == NFCReaderError.readerSessionInvalidationErrorUserCanceled {
            self.sendWebviewMessage("window.__verify_ios_tag_disconnected(true)")
        } else {
            self.sendWebviewMessage("window.__verify_ios_tag_disconnected(false)")
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        DispatchQueue.main.async {
            if tags.count > 1 {
                session.alertMessage = Verify.localize(
                    from: "More than 1 tag is detected. Please remove all tags and try again."
                )
                DispatchQueue.global().asyncAfter(deadline: .now() + self.retryInterval) {
                    session.restartPolling()
                }
                return
            }

            guard let tag = tags.first else {
                return
            }
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
                            session.invalidate(
                                errorMessage: Verify.localize(from: "Connection error. Please try again.")
                            )
                            return
                        }
                    }

                    if let nfcTag {
                        if try await self.resetReaderSession(tag: nfcTag) {
                            self.startTagReading()
                        }
                    }
                } catch let error {
                    if Verify.shared.debug {
                        Verify.logger.error("Error while reading session: \(error)")
                    }
                    session.invalidate(errorMessage: Verify.localize(from: "Connection error. Please try again."))
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
            readerSession?.alertMessage = Verify.localize(from: "Hold your iPhone near the document.")
            readerSession?.begin()
        }
    }

    func nfcStop(body: [String: AnyObject]) {
        readerSession?.alertMessage = ""
        if let error = body["error"] as? String {
            readerSession?.invalidate(errorMessage: error)
        } else {
            readerSession?.invalidate()
        }
    }

    func nfcTransmit(body: [String: AnyObject]) async {
        guard let apdu = body["apdu"] as? String else {
            return
        }

        if readerSession?.isReady ?? false {
            if let percentage = body["progress"] as? Int, isProgress {
                let progress = genProgress(percentage: percentage)
                readerSession?.alertMessage = "\(self.step ?? Verify.localize(from: "Loading..."))\n \(progress)"
            } else {
                readerSession?.alertMessage = self.step ?? Verify.localize(from: "Loading...")
            }
        }


        if let tag = self.nfcTag {
            do {
                let responseApdu = try await self.sendCommand(tag: tag, command: apdu)
                DispatchQueue.main.async {
                    self.sendToWebviewResponseApdu(responseApdu)
                }
            } catch {
                self.sendWebviewMessage("window.__verify_ios_tag_disconnected(false)")
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) { [self] in
                    readerSession?.restartPolling()
                }
            }
        }
    }

    func nfcStep(body: [String: AnyObject]) {
        guard let value = body["step"] as? String else { return }
        self.step = value
        if self.step?.lowercased() == "authenticate" {
            AudioServicesPlaySystemSound(1519)
        }
        if let isProgressString = body["progress"] as? Int {
            self.isProgress = (isProgressString != 0)
        }
    }

    func nfcLog(body: [String: AnyObject]) {
        if Verify.shared.debug {
            Verify.logger.debug("\(body)")
        }
    }

    func localize(body: [String: AnyObject]) {
        if let translations = body["translations"] as? [String: String] {
            Verify.translations = translations
        }
    }

    func cameraRequestPermission(body: [String: AnyObject]) {
        let granted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        self.sendWebviewMessage("window.__verify_ios_camera_permission(\(granted)")
    }

    private func genProgress(percentage: Int) -> String {
        var progress = ""
        var cursor = 0
        while cursor < (percentage / 10) {
            progress.append("🟦")
            cursor += 1
        }
        cursor = 0
        while cursor < (10 - (percentage / 10)) {
            progress.append("⬜️")
            cursor += 1
        }
        return progress
    }
}
