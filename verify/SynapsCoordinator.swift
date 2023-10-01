//
//  SynapsCoordinator.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import WebKit
import CoreNFC

protocol SynapsNfcEvent {
    func nfcStart()
    func nfcStop()
    func nfcTransmit(body: [String: AnyObject])
    func nfcStep(body: [String: AnyObject])
}

@available(iOS 15.0, *)
public class SynapsCoordinator: NSObject {
	private var readerSession: NFCTagReaderSession?

	private var finished: Bool = false
	private var apduContinuation: CheckedContinuation<String, Never>? = Optional.none
	private var apdu: String? = Optional.none

	private var step: String?
	private var cursor: Int = 0
	private var length: Int = -1
	private var retry: Int = 0

	private var nfcTag: NFCISO7816Tag? = nil

	var parent: SynapsView

	internal init(_ parent: SynapsView) {
		self.parent = parent
	}
}

@available(iOS 15.0, *)
extension SynapsCoordinator: WKScriptMessageHandler {
	@MainActor public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		print("LOG: \(message.body)")
        guard message.name == "verify" || message.name == "synaps" else {
            return
        }
        if let body = message.body as? String {
            switch body {
            case "ready":
                parent.viewModel.onReady?()
            case "finished":
                parent.viewModel.onFinished?()
            default:
                break
            }
        } else if let body = message.body as? [String: AnyObject] {
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
				break;
                //print("log")
            case "step":
                nfcStep(body: body)
            default:
                break
            }
        }
	}
}

extension SynapsCoordinator: NFCTagReaderSessionDelegate {
	public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
		print("tagReaderSessionDidBecomeActive")
	}

	public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
		print("Error while reading tag")
		print(error)
		cleanup()
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
				print("Invalid tag type")
				return
			}

			Task { [nfcTag = self.nfcTag] in
				print("tag read")
				do {
					session.connect(to: tag) { (error: Error?) in
						if error != nil {
							session.invalidate(errorMessage: "Connection error. Please try again.")
							return
						}
					}

					if let nfcTag {
						if try await self.resetSession(tag: nfcTag) {
							try await self.start(tag: nfcTag)
						}
					}
				} catch let error {
					print("Error while reading session: \(error)")
					self.cleanup()
				}
			}
		}
	}

	func resetSession(tag: NFCISO7816Tag) async throws -> Bool {
		print("try to reset")
		let selectCommand = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA4, p1Parameter: 0x00, p2Parameter: 0x00, data: Data(), expectedResponseLength: 256)

		print("try send command")
		let (_, sw1, sw2) = try await tag.sendCommand(apdu: selectCommand)
		if sw1 == 0x90 && sw2 == 0x00 {
			print("Session reset successfully")
			return true
		}

		print("Session reset failed. SW: \(String(format: "%02X", sw1))\(String(format: "%02X", sw2))")
		return false
	}

	func start(tag: NFCISO7816Tag) async throws {
		self.finished = false

		print("Sending connected")
		DispatchQueue.main.async {
			self.tagConnected()
		}

		while true {
			let message = await waitForMessage()

			if finished {
				print("Finished")
				return
			}

			self.apdu = Optional.none

			let rapdu = try await self.send(tag: tag, message)
			DispatchQueue.main.async {
				self.response(rapdu)

			}
		}
	}

	func sendMessage(_ newApdu: String) {
		if let continuation = apduContinuation {
			apduContinuation = Optional.none
			continuation.resume(returning: newApdu)
		} else {
			apdu = newApdu
		}
	}

	func waitForMessage() async -> String {
        print("start waiting")
		if let existingMessage = apdu {
			apdu = Optional.none
			return existingMessage
		} else {
			return await withCheckedContinuation { (continuation: CheckedContinuation<String, Never>) in
				apduContinuation = continuation
			}
		}
	}

	func send(tag: NFCISO7816Tag, _ command: String) async throws -> Data {
		let cmd = Data(base64Encoded: command)!
		let apdu = NFCISO7816APDU(data: cmd)!

		var (data, sw1, sw2) = try await tag.sendCommand(apdu: apdu)
		data.append(sw1)
		data.append(sw2)
		return data
	}

	private func sendWebviewMessage(_ cmd: String) {
		DispatchQueue.main.async {
			self.parent.viewModel.onMessage?(cmd)
		}
	}

	private func tagConnected() {
		self.sendWebviewMessage("window.__verify_ios_tag_connected()")
	}

	private func tagDisconnected() {
		readerSession?.invalidate()
		self.sendWebviewMessage("window.__verify_ios_tag_disconnected()")
	}

	private func response(_ rapdu: Data) {
		self.sendWebviewMessage("window.__verify_ios_rapdu('\(rapdu.base64EncodedString())')")
	}

	private func cleanup() {
		if !finished {
			finished = true
			sendMessage("")
			self.apduContinuation = Optional.none
			self.apdu = Optional.none
			DispatchQueue.main.async {
				print("Dispatch response")
				self.tagDisconnected()
			}
		}
	}
}

extension SynapsCoordinator: SynapsNfcEvent {
    func nfcStart() {
        guard NFCNDEFReaderSession.readingAvailable else {
            // TODO: Handle the error (send a message to the webview)
            print("Reading unavailable")
            return
        }

        if NFCTagReaderSession.readingAvailable {
            readerSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
            readerSession?.alertMessage = "Hold your iPhone near the item to learn more about it."
            readerSession?.begin()
        }
    }

    func nfcStop() {
        if !finished {
            finished = true
            sendMessage("")
            readerSession?.invalidate()
        }
    }

    func nfcTransmit(body: [String: AnyObject]) {
        guard let apdu = body["apdu"] as? String else {
            return
        }
        sendMessage(apdu)

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
}

extension Data {
	struct HexEncodingOptions: OptionSet {
		let rawValue: Int
		static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
	}

	func hexEncodedString(options: HexEncodingOptions = []) -> String {
		let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
		return self.map { String(format: format, $0) }.joined()
	}
}
