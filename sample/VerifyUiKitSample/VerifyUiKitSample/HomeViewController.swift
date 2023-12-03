//
//  HomeViewController.swift
//  VerifyUiKitSample
//
//  Created by Jamy Bailly on 03/12/2023.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sessionTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!

    var authorizationCamera = false
    let defaultSessionId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        updateScreen()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func updateScreen() {
        sessionTextField.delegate = self
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            authorizationCamera = true
        }
        if authorizationCamera {
            titleLabel.text = "Enter your session ID"
            sessionTextField.placeholder = "Session ID"
            sessionTextField.isHidden = false
            sessionTextField.text = defaultSessionId
            startButton.setTitle("Start", for: .normal)
        } else {
            titleLabel.text = "Camera access required"
            sessionTextField.isHidden = true
            startButton.setTitle("Ask camera permission", for: .normal)
        }
    }

    func requestPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        } else {
            AVCaptureDevice.requestAccess(
                for: .video
            ) { accessGranted in
                DispatchQueue.main.async {
                    self.authorizationCamera = accessGranted
                    self.updateScreen()
                }
            }
        }
    }

    @IBAction func onStartButton(_ sender: Any) {
        if authorizationCamera {
            if let vc = storyboard?.instantiateViewController(
                withIdentifier: "VerifyViewController"
            ) as? VerifyViewController {
                vc.sessionId = sessionTextField.text ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            requestPermission()
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
