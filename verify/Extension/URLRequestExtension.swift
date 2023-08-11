//
//  URLRequest+Extension.swift
//  verify
//
//  Created by Jamy Bailly on 11/08/2023.
//

import Foundation

extension URLRequest {
	mutating func append(parameters: [String: String?]) {
		guard let url = url, var urlComponents = URLComponents(string: url.absoluteString) else {
			return
		}

		urlComponents.queryItems = parameters.map { key, value in
			URLQueryItem(name: key, value: value)
		}
		self.url = urlComponents.url
	}
}
