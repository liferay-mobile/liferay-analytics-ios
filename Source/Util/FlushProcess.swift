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
internal class FlushProcess {
	
	init(endpointURL: String, fileStorage: FileStorage, flushInterval: Int) {
		self.endpointURL = endpointURL
		self.eventsDAO = EventsDAO(fileStorage: fileStorage)
		self.userDAO = UserDAO(fileStorage: fileStorage)
		self.flushInterval = flushInterval
		
		flush()
	}
	
	func addEvent(event: Event) {
		let userId = getUserId()
		
		if (isInProgress) {
			eventsQueue[userId] = (eventsQueue[userId] ?? []) + [event]
			
			return
		}
		
		eventsDAO.addEvents(userId: userId, events: [event])
	}
	
	func flush() {
		let time = DispatchTime.now() + .seconds(flushInterval)
		
		DispatchQueue.global(qos: .background)
			.asyncAfter(deadline: time) { [weak self] in
			self?.sendEvents()
			
			self?.flush()
		}
	}

	func getUserId() -> String {
		guard let userId = userDAO.getUserId(), !userId.isEmpty else {
			let identityContext = try! Analytics.getInstance().getDefaultIdentityContext()
			
			userDAO.addUserContext(identity: identityContext)
			userDAO.setUserId(userId: identityContext.userId)
			
			return identityContext.userId
		}
		
		return userId
	}
	
	func saveEventsQueue() {
		while (!eventsQueue.isEmpty) {
			guard let (userId, events) = eventsQueue.popFirst() else {
				continue
			}
			
			eventsDAO.addEvents(userId: userId, events: events)
		}
	}
	
	func send(events: [Event], for userId: String) throws {
		let instance = try! Analytics.getInstance()
		
		var currentEvents = events
		while !currentEvents.isEmpty {
			let eventsToSend = Array(currentEvents.prefix(FLUSH_SIZE))
			
			let analyticsEvents = AnalyticsEvents(
				dataSourceId: instance.dataSourceId, userId: userId) {
				
				$0.events = eventsToSend
			}
			
			let _ = try analyticsClient.send(
				endpointURL: instance.endpointURL, analyticsEvents: analyticsEvents)
			
			currentEvents = Array(currentEvents.dropFirst(FLUSH_SIZE))
			eventsDAO.updateEvents(userId: userId, events: currentEvents)
		}
	}
	
	func sendEvents() {
		do {
			isInProgress = true
			
			var userIdsEvents = eventsDAO.getEvents()
			
			for (userId, currentEvents) in userIdsEvents {
				try send(events: currentEvents, for: userId)
				
				userIdsEvents.removeValue(forKey: userId)
				eventsDAO.replaceEvents(events: userIdsEvents)
			}
			
			try sendIdentities()
		}
		catch let error {
			print("Could not flush events: \(error.localizedDescription)")
		}
		defer {
			isInProgress = false
			saveEventsQueue()
		}
	}
	
	func sendIdentities() throws {
		let identityContext = IdentityClient()
		
		var userContexts = userDAO.getUserContexts()
		while (!userContexts.isEmpty) {
			guard let userContext = userContexts.popLast() else {
				continue
			}
			
			try identityContext.send(endpointURL: endpointURL, identityContext: userContext)
			userDAO.replaceUserContexts(identities: userContexts)
		}
	}
	
	let FLUSH_SIZE = 100
	
	let analyticsClient = AnalyticsClient()
	let endpointURL: String
	let eventsDAO: EventsDAO
	var eventsQueue = [String: [Event]]()
	let flushInterval: Int
	var isInProgress = false
	let userDAO: UserDAO
}
