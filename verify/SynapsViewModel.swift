//
//  File.swift
//  
//
//  Created by Jamy Bailly on 30/07/2023.
//

import AVFoundation
import Combine

@available(iOS 15.0, *)
@MainActor class SynapsViewModel : ObservableObject {
	@Published var ready = false

    var onReady: (() -> Void)? = nil
	var onFinished: (() -> Void)? = nil
	
	var anyCancellables = Set<AnyCancellable>()
}
