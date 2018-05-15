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
internal class IdentityContext: Codable {

	init(analyticsKey: String, build: ((IdentityContext) -> ())? = nil) {
		self.analyticsKey = analyticsKey
		self.userId = IdentityContext.createUserId()
		
		build?(self)
	}
	
	class func createUserId() -> String {
		let uuid = NSUUID().uuidString
		let lastIndex = uuid.index(uuid.startIndex, offsetBy: 19)
		
		return String(uuid[...lastIndex])
	}

	let analyticsKey: String
	var identity: Identity?
	var language: String?
	var platform: String?
	var timezone: String?
	let userId: String
}
