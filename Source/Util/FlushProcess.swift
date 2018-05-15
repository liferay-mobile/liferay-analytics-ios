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
	
	init(fileStorage: FileStorage, flushInterval: Int) {
		self.eventsDAO = EventsDAO(fileStorage: fileStorage)
		self.userDAO = UserDAO(fileStorage: fileStorage)
		self.flushInterval = flushInterval
		
		flush()
	}
	
	func addEvent(event: Event) {
		if (isInProgress){
			let userId = getUserId()
			
			eventsQueue[userId] = (eventsQueue[userId] ?? []) + [event]
			
			return
		}
		
		let userId = getUserId()
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
			let instance = try! Analytics.getInstance()
			let identityContext = instance.getDefaultIdentityContext()
			
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
	
	func send(userId: String, events: [Event]) throws {
		let instance = try! Analytics.getInstance()
		
		var currentEvents = events
		while !currentEvents.isEmpty {
			let eventsToSend = Array(currentEvents.prefix(FLUSH_SIZE))
			
			let message = AnalyticsEventsMessage(
			analyticsKey: instance.analyticsKey, userId: userId) {
				
				$0.events = eventsToSend
			}
			
			let _ = try analyticsClient.sendAnalytics(analyticsEventsMessage: message)
			
			currentEvents = Array(currentEvents.dropFirst(FLUSH_SIZE))
			eventsDAO.updateEvents(userId: userId, events: currentEvents)
		}
	}
	
	func sendEvents() {
		do {
			isInProgress = true
			
			var userIdsEvents = eventsDAO.getEvents()
			for (userId, currentEvents) in userIdsEvents {
				try send(userId: userId, events: currentEvents)
				
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
		let identityContextImpl = IdentityClientImpl()
		
		var userContexts = userDAO.getUserContexts()
		while (!userContexts.isEmpty) {
			guard let userContext = userContexts.popLast() else {
				continue
			}
			
			try identityContextImpl.send(identityContext: userContext)
			userDAO.replaceUserContexts(identities: userContexts)
		}
	}
	
	let FLUSH_SIZE = 100
	
	let analyticsClient = AnalyticsClientImpl()
	let eventsDAO: EventsDAO
	var eventsQueue = [String: [Event]]()
	let flushInterval: Int
	var isInProgress = false
	let userDAO: UserDAO
}
