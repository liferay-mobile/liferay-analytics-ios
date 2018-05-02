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
		
		try! Analytics.init(analyticsKey: "AnalyticsKey")
		let analytics = try! Analytics.getInstance()
		
		flushProcess = analytics.flushProcess
		
		eventsDAO = flushProcess.eventsDAO
		userDAO = flushProcess.userDAO
		
		eventsDAO.replaceEvents(events: [])
	}
	
	func replaceEvents(size: Int) {
		var events = [Event]()
		for i in 1...size {
			events.append(Event(applicationId: "appId\(i)", eventId: "event\(i)"))
		}
		
		eventsDAO.replaceEvents(events: events)
	}
	
	func testAddEvents() {
		let event1 = Event(applicationId: "appId1", eventId: "View1")
		let event2 = Event(applicationId: "appId2", eventId: "View2")
		
		flushProcess.addEvent(event: event1)
		
		assert(eventsDAO.getEvents().count == 1)
		assert(flushProcess.eventsQueue.count == 0)
		
		flushProcess.isInProgress = true
		flushProcess.addEvent(event: event2)
		
		assert(eventsDAO.getEvents().count == 1)
		assert(flushProcess.eventsQueue.count == 1)
	}
	
	func testGetEventsToSave() {
		var events = flushProcess.getEventsToSave()
		assert(events.count == 0)
		
		replaceEvents(size: 1)
		events = flushProcess.getEventsToSave()
		assert(events.count == 0)
		
		replaceEvents(size: 101)
		events = flushProcess.getEventsToSave()
		assert(events.count == 1)
		assert(events.first!.eventId == "event101")
		
		replaceEvents(size: 250)
		events = flushProcess.getEventsToSave()
		assert(events.count == 150)
		assert(events.first!.eventId == "event101")
		assert(events.last!.eventId == "event250")
	}
	
	func testGetEventsToSend() {
		var events = flushProcess.getEventsToSend()
		assert(events.count == 0)
		
		replaceEvents(size: 1)
		events = flushProcess.getEventsToSend()
		assert(events.count == 1)
		assert(events.last!.eventId == "event1")
		
		replaceEvents(size: 101)
		events = flushProcess.getEventsToSend()
		assert(events.count == 100)
		assert(events.first!.eventId == "event1")
		assert(events.last!.eventId == "event100")
		
		replaceEvents(size: 250)
		events = flushProcess.getEventsToSend()
		assert(events.count == 100)
		assert(events.first!.eventId == "event1")
		assert(events.last!.eventId == "event100")
	}
	
	func testGetUserIdLocally() {
		userDAO.setUserId(userId: "userId1")
		
		let userId = try! flushProcess.getUserId()
		assert(userId == "userId1")
	}
	
	func testGetUserIdRemotelly() {
		userDAO.clearSession()
		
		let userId = try! flushProcess.getUserId()
		assert(!userId.isEmpty)
	}
	
	var eventsDAO: EventsDAO!
	var flushProcess: FlushProcess!
	var userDAO: UserDAO!
}

