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
class AnalyticsTest: XCTestCase {
	
	override func setUp() {
		let fileStorage = try! FileStorage()
		
		let eventsDAO = EventsDAO(fileStorage: fileStorage)
		try! fileStorage.setString(
			key: eventsDAO.STORAGE_KEY_EVENTS, value: "[]")
	}
	
	override func tearDown() {
		Analytics.sharedInstance = nil
	}
	
	func testClearSession() {
		do {
			try Analytics.configure(analyticsKey: "AnalyticsKey")
			let instance = try Analytics.getInstance()
			
			Analytics.setIdentity(email: "email@liferay.com", name: "Liferya")
			var userId = instance.userDAO.getUserId() ?? ""
			XCTAssertFalse(userId.isEmpty)
			
			Analytics.clearSession()
			userId = instance.userDAO.getUserId() ?? ""
			XCTAssertTrue(userId.isEmpty)
		}
		catch {
			assertionFailure()
		}
	}
	
	func testInitAnalytics() {
		do {
			try Analytics.configure(analyticsKey: "AnalyticsKey")
			let instance = try Analytics.getInstance()
			
			assert(instance.analyticsKey == "AnalyticsKey")
		}
		catch {
			assertionFailure()
		}
	}
	
	func testInitAnalyticsTwice() {
		do {
			try Analytics.configure(analyticsKey: "AnalyticsKey")
			try Analytics.configure(analyticsKey: "AnalyticsKey")
		}
		catch let error {
			assert(error is AnalyticsError)
			let analyticsError = error as? AnalyticsError
			
			XCTAssertEqual(analyticsError, .analyticsAlreadyInitialized)
		}
	}
	
	func testSendAnalytics() {
		do {
			try Analytics.configure(analyticsKey: "AnalyticsKey")
			Analytics.send(eventId: "eventId1", applicationId: "app1")
			
			let instance = try Analytics.getInstance()
			let events = instance.flushProcess.eventsDAO.getEvents()
			
			XCTAssertEqual(events.count, 1)
		}
		catch {
			assertionFailure()
		}
	}
	
	func testSetIdentity() {
		do {
			try Analytics.configure(analyticsKey: "AnalyticsKey")
			Analytics.setIdentity(email: "email1", name: "name1")
			
			guard let identity = try Analytics.getInstance().userDAO.getUserContexts().last else {
				assertionFailure()
				
				return
			}
			
			XCTAssertEqual(identity.identity?.name, "name1")
			XCTAssertEqual(identity.identity?.email, "email1")
		}
		catch {
			assertionFailure()
		}
	}
}
