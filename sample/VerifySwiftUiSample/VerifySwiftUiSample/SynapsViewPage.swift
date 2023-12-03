//
//  SynapsViewPage.swift
//  VerifySwiftUiSample
//
//  Created by Jamy Bailly on 03/12/2023.
//

import SwiftUI
import SynapsVerify

struct SynapsViewPage: View {
    @Environment(\.dismiss) var dismiss
    @Binding var sessionId: String

    var body: some View {
        VerifyView(
            sessionId: self.sessionId,
            lang: .french,
            tier: nil
        )
        .onReady {
            print("onReady")
        }
        .onFinished {
            print("onFinish")
        }
        .navigationBarHidden(true)
    }
}
