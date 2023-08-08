//
//  File.swift
//  
//
//  Created by Jamy Bailly on 30/07/2023.
//

import AVFoundation
import Combine

@available(iOS 15.0, *)
extension SynapsView {
	@MainActor class ViewModel : ObservableObject {
		@Published var permissionGranted = false

		var anyCancellables = Set<AnyCancellable>()

		func requestPermission() {
			AVCaptureDevice.requestAccess(
				for: .video,
				completionHandler: { accessGranted in
					DispatchQueue.main.async {
						self.permissionGranted = accessGranted
						print("PERMISSION GRANTED: \(self.permissionGranted)")
					}
				}
			)
		}
	}
}
