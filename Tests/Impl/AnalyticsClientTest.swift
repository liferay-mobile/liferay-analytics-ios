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
					
				let eventView =
					Event(applicationId: "ApplicationId", eventId: "View") {
						$0.properties.updateValue("banner1", forKey: "elementId")
					}
				
				$0.events = [eventView]
				$0.protocolVersion = "1.0"
		}
		
		do {
			let _ = try _analyticsClient.send(analyticsEvents: analyticsEvents)
		}
		catch {
			assertionFailure()
		}
	}
	
	private struct AnalyticsEventsStruct: Codable {
		var analyticskey: String
		var userid: String
	}
	
	private func _getUserId() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy.MM.dd.HH.mm.ss"
		
		return "iOS\(formatter.string(from: Date()))"
	}
	private let _analyticsClient = AnalyticsClient()
	private var _userId: String!
	
}
