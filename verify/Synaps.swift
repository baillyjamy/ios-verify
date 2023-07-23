//
//  Synaps.swift
//  verify
//
//  Created by Omar Sy on 25/05/2022.
//

import Foundation

internal class Synaps {
	static let baseUrlIndividual = "https://verify.synaps.io/"
	static let baseUrlCorporate = "https://verify-v3.synaps.io/"
}


enum VerifyType {
	case individual
	case corporate

	var url: URL {
		switch self {
		case .individual:
			return URL(string: Synaps.baseUrlIndividual)!
		case .corporate:
			return URL(string: Synaps.baseUrlCorporate)!
		}
	}
}
