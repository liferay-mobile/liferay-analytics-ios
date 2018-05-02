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
class EventsDAOTest: XCTestCase {
	
	override func setUp() {
		let fileStorage = try! FileStorage()
		
		eventsDAO = EventsDAO(fileStorage: fileStorage)
		try! fileStorage.setString(
			key: eventsDAO.STORAGE_KEY_EVENTS, value: "[]")
		
		addTestEvents()
	}
	
	override func tearDown() {
		try! FileStorage().setString(
			key: eventsDAO.STORAGE_KEY_EVENTS, value: "[]")
	}
	
	func addTestEvents() {
		let events = [Event(applicationId: "appId1", eventId: "View1"),
					  Event(applicationId: "appId2", eventId: "View2"),
					  Event(applicationId: "appId3", eventId: "View3"),
					  Event(applicationId: "appId4", eventId: "View4"),
					  Event(applicationId: "appId5", eventId: "View5")]
		
		eventsDAO.addEvents(events: events)
	}
	
	func testAddEvents() {
		let events = eventsDAO.getEvents()
		
		assert(events.count == 5)
		assert(events.first?.applicationId == "appId1")
		assert(events.last?.applicationId == "appId5")
	}
	
	
	func testGetGroupedEvents() {
		var events = eventsDAO.getEvents()
		
		assert(events.count == 5)
		eventsDAO.replaceEvents(events: [])
		events = eventsDAO.getEvents()
		assert(events.count == 0)
	}
	
	var eventsDAO: EventsDAO!
}
