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
internal class Event: Codable {
	init(applicationId: String, eventId: String, build: ((Event) -> Void)? = nil) {
		self.applicationId = applicationId
		self.eventId = eventId

		build?(self)
    }
    
    internal let applicationId: String
    internal let eventDate = Date()
    internal var eventId: String
    internal var properties = [String: String]()
}
