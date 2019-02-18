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
class FlushProcessTest: XCTestCase {
	
	override func setUp() {
		Analytics.sharedInstance = nil
		
		try! Analytics.init()
		let analytics = try! Analytics.getInstance()
		
		flushProcess = analytics.flushProcess
		
		eventsDAO = flushProcess.eventsDAO
		userDAO = flushProcess.userDAO
		
		eventsDAO.replaceEvents(events: [:])
	}
	
	func testAddEvents() {
		let event1 = Event(applicationId: "appId1", eventId: "View1")
		let event2 = Event(applicationId: "appId2", eventId: "View2")
		
		flushProcess.addEvent(event: event1)
		
		XCTAssertEqual(eventsDAO.getEvents().count, 1)
		XCTAssertEqual(flushProcess.eventsQueue.count, 0)
		
		flushProcess.isInProgress = true
		flushProcess.addEvent(event: event2)
		
		XCTAssertEqual(eventsDAO.getEvents().count, 1)
		XCTAssertEqual(flushProcess.eventsQueue.count, 1)
	}
	
	func testGetNewUserId() {
		userDAO.setUserId(userId: "userId1")
		userDAO.clearSession()
		
		let userId = flushProcess.getUserId()
		XCTAssertFalse(userId.isEmpty)
		XCTAssertNotEqual(userId, "userId1")
		XCTAssertEqual(userId.count, 20)
	}
	
	func testGetUserIdLocally() {
		userDAO.setUserId(userId: "userId1")
		
		let userId = flushProcess.getUserId()
		XCTAssertEqual(userId, "userId1")
	}
	
	func testSaveEventsToQueue() {
		flushProcess.isInProgress = true
		let userId = flushProcess.getUserId()
		
		for i in 1...10 {
			let event = Event(applicationId: "appId\(i)", eventId: "event\(i)")
			flushProcess.addEvent(event: event)
		}
		XCTAssertEqual(flushProcess.eventsQueue[userId]?.count, 10)
		XCTAssertNil(eventsDAO.getEvents()[userId])
		
		flushProcess.saveEventsQueue()
		
		XCTAssertNil(flushProcess.eventsQueue[userId])
		XCTAssertEqual(eventsDAO.getEvents()[userId]?.count, 10)
	}
	
	var eventsDAO: EventsDAO!
	var flushProcess: FlushProcess!
	var userDAO: UserDAO!
}
