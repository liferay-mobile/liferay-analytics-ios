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
- Author: Marcelo Mello
*/
extension Date {
	func formatAsUTC() -> Date {
		let DATE_FORMAT: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		let DATE_ABBREVIATION: String = "UTC"
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: DATE_ABBREVIATION)
		dateFormatter.dateFormat = DATE_FORMAT
		
		return dateFormatter.date(from: dateFormatter.string(from: self)) ?? self
	}
}
