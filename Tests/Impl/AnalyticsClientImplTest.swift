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

import XCTest

/**
* @author Allan Melo
*/
class AnalyticsClientImplTest: XCTestCase {
	
	override func setUp() {
		_userId = _getUserId()
	}

	func testSendAnalytics() {
		let analyticsEventsMessage =
			AnalyticsEventsMessage(analyticsKey: "liferay.com") {
				$0.userId = _userId
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
		let _ = try! _analyticsClientImpl.sendAnalytics(
			analyticsEventsMessage: analyticsEventsMessage)
		
		let result = try! _getAnalyticsEventMessage(userId: _userId)
		
		XCTAssertEqual(result.userid, analyticsEventsMessage.userId)
	}
	
	private struct AnalyticsEventsMessageStruct: Codable {
		var analyticskey: String
		var userid: String
	}
	
	private func _getAnalyticsEventMessage(userId: String)
		throws -> AnalyticsEventsMessageStruct {
			
		let body = _getQuery().data(using: .utf8)!
		let result = URLSession.sendPost(url: _CASSANDRA_URL, body: body)
			
		if let error = result.2 {
			throw error
		}

		let data = result.0!
		let decoder = JSONDecoder()
			
		return try decoder.decode(
			[AnalyticsEventsMessageStruct].self, from: data).first!

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
	
	private let _analyticsClientImpl = AnalyticsClientImpl()
	private var _userId: String!
	
	private let _CASSANDRA_URL =
		URL(string: "http://192.168.108.90:9095/api/query/execute")!
}
