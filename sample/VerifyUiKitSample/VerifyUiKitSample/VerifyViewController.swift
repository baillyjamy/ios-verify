//
//  VerifyViewController.swift
//  VerifyUiKitSample
//
//  Created by Jamy Bailly on 03/12/2023.
//

import UIKit
import SynapsVerify

class VerifyViewController: UIViewController {
    @IBOutlet weak var verifyView: VerifyUiView!

    var sessionId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        verifyView.startSession(sessionId: sessionId, lang: .french)
        verifyView.onReady {
            print("onReady")
        }
        verifyView.onFinished {
            print("onFinish")
            self.navigationController?.popViewController(animated: true)
        }
    }
}
