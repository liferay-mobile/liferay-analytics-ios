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
class AnalyticsClientImpl: AnalyticsClient {
    
    init() {
		let bundle = Bundle(for: type(of: self))
		var settings: [String: String]?
		
		if let path = bundle.path(forResource: "settings", ofType:"plist") {
			settings = NSDictionary(contentsOfFile: path) as? [String: String]
		}

		GATEWAY_HOST = settings?["ANALYTICS_GATEWAY_HOST"] ?? ""
		GATEWAY_PATH = settings?["ANALYTICS_GATEWAY_PATH"] ?? ""
		GATEWAY_PORT = settings?["ANALYTICS_GATEWAY_PORT"] ?? ""
		GATEWAY_PROCOTOL = settings?["ANALYTICS_GATEWAY_PROTOCOL"] ?? ""

		baseUrl = URL(string: String(format:"%@://%@:%@%@" , GATEWAY_PROCOTOL,
									 GATEWAY_HOST, GATEWAY_PORT, GATEWAY_PATH))
    }
    
	internal func sendAnalytics(analyticsEventsMessage: AnalyticsEventsMessage)
		throws -> String {
			
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let analyticsMessageData = try encoder.encode(analyticsEventsMessage)
			
		guard let url = baseUrl else {
			throw HttpError.invalidUrl
		}
		
		let (data, _, error) = URLSession.sendPost(
			url: url, body: analyticsMessageData)

		if let error = error {
			// TO DO OFFLINE JOB
			let saveData = String(data: analyticsMessageData, encoding: .utf8)!
			
			throw error
		}
		
		guard let resultData = data,
			let result = String(data: resultData, encoding: .utf8) else {
				
			return ""
		}
			
		return result
    }
    
	private let baseUrl: URL?

	private let GATEWAY_HOST: String
	private let GATEWAY_PATH: String
	private let GATEWAY_PORT: String
	private let GATEWAY_PROCOTOL: String

}
