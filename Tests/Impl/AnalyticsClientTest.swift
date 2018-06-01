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

@testable import liferay_analytics
import XCTest

/**
* @author Allan Melo
*/
class AnalyticsClientTest: XCTestCase {
	
	override func setUp() {
		_userId = _getUserId()
	}

	func testSendAnalytics() {
		let analyticsEvents = AnalyticsEvents(
			analyticsKey: "liferay.com", userId: _userId) {
				$0.context.updateValue("pt_PT", forKey: "languageId")
				$0.context.updateValue(
					"http://192.168.108.90:8081", forKey: "url")
					
				let eventView =
					Event(applicationId: "ApplicationId", eventId: "View") {
						$0.properties.updateValue(
							"banner1", forKey: "elementId")
				}
				
				$0.events = [eventView]
				$0.protocolVersion = "1.0"
		}
		
		var userIdResult = ""
		do {
			let _ = try _analyticsClient.send(analyticsEvents: analyticsEvents)
			
			userIdResult = try! _getAnalyticsEvent(userId: _userId).userid
			
		}
		catch {}
		
		XCTAssertEqual(userIdResult, analyticsEvents.userId)
	}
	
	private struct AnalyticsEventsStruct: Codable {
		var analyticskey: String
		var userid: String
	}
	
	private func _getAnalyticsEvent(userId: String) throws -> AnalyticsEventsStruct {
		let body = _getQuery().data(using: .utf8)!
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 3000
            config.timeoutIntervalForResource = 3000

            let result = URLSession.sendPost(url: _CASSANDRA_URL, body: body, config: config)
			
		if let error = result.2 {
			throw error
		}

		let data = result.0!
		let decoder = JSONDecoder()
			
		return try decoder.decode([AnalyticsEventsStruct].self, from: data).first!
	}
	
	private func _getQuery() -> String {
		return """
		{"keyspace":"analytics",
		 "table":"analyticsevent",
		 "conditions" : [{"name":"userId",
						  "operator":"eq",
		                  "value": "\(_userId!)"}]}
		"""
	}
	
	private func _getUserId() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy.MM.dd.HH.mm.ss"
		
		return "iOS\(formatter.string(from: Date()))"
	}
	
	private let _analyticsClient = AnalyticsClient()
	private var _userId: String!
	
	private let _CASSANDRA_URL = URL(string: "http://192.168.108.90:9095/api/query/execute")!
}
