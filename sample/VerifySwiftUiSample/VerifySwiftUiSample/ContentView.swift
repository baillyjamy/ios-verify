//
//  ContentView.swift
//  VerifySwiftUiSample
//
//  Created by Jamy Bailly on 03/12/2023.
//

import SwiftUI
import AVFoundation
import SynapsVerify

struct ContentView: View {
    @State var authorizationCamera: Bool = false

    @State private var sessionId: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image(uiImage: UIImage(named: "AppIcon")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200.0, height: 200.0)
                    .foregroundColor(.accentColor)
                    .background(Color.red)
                if (authorizationCamera) {
                    Text("Enter your session ID")
                    TextField("Session ID", text: $sessionId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    NavigationLink(destination: SynapsViewPage(sessionId: $sessionId)) {
                        Text("Start")
                    }
                } else {
                    Text("Camera access required")
                    Button("Ask camera permission") {
                        requestPermission()
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                authorizationCamera = true
            }
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
                for: .video,
                completionHandler: { accessGranted in
                    DispatchQueue.main.async {
                        self.authorizationCamera = accessGranted
                    }
                }
            )
        }
    }
}

#Preview {
    ContentView(authorizationCamera: true)
}
