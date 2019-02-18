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
internal class AnalyticsClient {
        
	func send(endpointURL: String, analyticsEvents: AnalyticsEvents)
		throws -> String {
		
		guard let url = URL(string: endpointURL) else {
			throw HttpError.invalidUrl
		}
            
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let analyticsData = try encoder.encode(analyticsEvents)
		
		let (data, _, error) = URLSession.sendPost(url: url, body: analyticsData)

		if let error = error {
			throw error
		}
		
		guard let resultData = data,
			let result = String(data: resultData, encoding: .utf8) else {
				
			return ""
		}
			
		return result
    }
}
