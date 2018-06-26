/**
* Copyright (c) 2000-present Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/

import Foundation

/**
- Author: Allan Melo
*/
class IdentityClient {
	
	init() {
		let bundle = Bundle(for: type(of: self))
		var settings: [String: String]?

		if let path = bundle.path(forResource: "settings", ofType:"plist") {
			settings = NSDictionary(contentsOfFile: path) as? [String: String]
		}
		
		baseUrl = URL(string: settings?["IDENTITY_GATEWAY"] ?? "")
	}
	
	func send(identityContext: IdentityContext) throws {
		guard let url = baseUrl else {
			throw HttpError.invalidUrl
		}
			
		let encoder = JSONEncoder()
		let identityContextData = try encoder.encode(identityContext)
			
		let (_, _, error) = URLSession.sendPost(url: url, body: identityContextData)
		
		if let error = error {
			throw error
		}
	}
	
	private let baseUrl: URL?
	
}
