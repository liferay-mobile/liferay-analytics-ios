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
			addToQueue(event: event)
			
			return
		}
		
		 eventsDAO.addEvents(events: [event])
	}
	
	func addToQueue(event: Event) {
		eventsQueue.append(event)
	}
	
	func flush() {
		let time = DispatchTime.now() + .seconds(flushInterval)
		
		DispatchQueue.global(qos: .background)
			.asyncAfter(deadline: time) { [weak self] in
			self?.sendEvents()
			
			self?.flush()
		}
	}
	
	func getEventsToSave() -> [Event] {
		let eventsDB = eventsDAO.getEvents()
		let minIndex = (eventsDB.count > FLUSH_SIZE ? FLUSH_SIZE : eventsDB.count)
		
		return Array(eventsDB[minIndex...])
	}
	
	func getEventsToSend() -> [Event] {
		let eventsDB = eventsDAO.getEvents()
		let maxIndex = (eventsDB.count > FLUSH_SIZE ? FLUSH_SIZE : eventsDB.count) - 1
		
		return Array(eventsDB[...maxIndex])
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
		eventsDAO.addEvents(events: eventsQueue)
		eventsQueue.removeAll()
	}
	
	func sendEvents() {
		do {
			isInProgress = true
			
			let instance = try! Analytics.getInstance()
			let userId = getUserId()
			
			var eventsDB = eventsDAO.getEvents()
			while !eventsDB.isEmpty {
				let events = getEventsToSend()

				let message = AnalyticsEventsMessage(
					analyticsKey: instance.analyticsKey, userId: userId) {
					
					$0.events = events
				}
				
				let _ = try analyticsClient.sendAnalytics(analyticsEventsMessage: message)
				
				eventsDB = getEventsToSave()
				eventsDAO.replaceEvents(events: eventsDB)
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
	var eventsQueue = [Event]()
	let flushInterval: Int
	var isInProgress = false
	let userDAO: UserDAO
}
