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
* @author Allan Melo
*/
class IdentityClientImpl: IdentityClient {
	
	func getUserId(identityContextMessage: IdentityContextMessage)
		throws -> String {
			
		guard let url = _getBaseURL(identityContextMessage.analyticsKey) else {
			throw HttpError.invalidUrl
		}
			
		let encoder = JSONEncoder()
		let identityContextMessageData = try encoder.encode(
			identityContextMessage)
			
		let (data, _, error) = URLSession.sendPost(
			url: url, body: identityContextMessageData)
		
		if let error = error {
			throw error
		}
		
		guard let resultData = data,
			let result = String(data: resultData, encoding: .utf8) else {
				
			return ""
		}
		
		return result
	}
	
	private func _getBaseURL(_ analyticsKey: String) -> URL? {
		return URL(string: String(format:"%@://%@:%@/%@%@" , GATEWAY_PROCOTOL,
								   GATEWAY_HOST, GATEWAY_PORT, analyticsKey,
								   GATEWAY_PATH))
	}
	
	
	private let GATEWAY_HOST = "contacts-prod.liferay.com"
	private let GATEWAY_PATH = "/identity"
	private let GATEWAY_PORT = "443"
	private let GATEWAY_PROCOTOL = "https"
}
