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
	
	func addEvents(event: Event) {
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
		let time = DispatchTime(
			uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) +
			Double(flushInterval * Int(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
		
		DispatchQueue.global(qos: .background)
			.asyncAfter(deadline: time) { [weak self] in
			self?.sendEvents()
			
			self?.flush()
		}
	}
	
	func getUserId() throws -> String {
		if let userId = userDAO.getUserId(), !userId.isEmpty {
			return userId
		}
		
		let instance = try! Analytics.getInstance()
		let userContext = userDAO.getUserContext() ?? instance.getDefaultIdentityContext()
		
		let identityContextImpl = IdentityClientImpl()
		
		let userId = try identityContextImpl.getUserId(identityContextMessage: userContext)
		
		userDAO.setUserId(userId: userId)
		
		return userId
	}
	
	func saveEventsQueue() {
		eventsDAO.addEvents(events: eventsQueue)
		eventsQueue.removeAll()
	}
	
	func sendEvents() {
		do {
			isInProgress = true
			let events = eventsDAO.getEvents()
			
			let instance = try! Analytics.getInstance()
			let userId = try getUserId()
			
			let message = AnalyticsEventsMessage(analyticsKey: instance.analyticsKey) {
				$0.userId = userId
				$0.events = events
			}
			
			let _ = try analyticsClient.sendAnalytics(
				analyticsEventsMessage: message)
			
			eventsDAO.replaceEvents(events: [])
		}
		catch let error {
			print("Could not flush events: \(error.localizedDescription)")
		}
		defer {
			isInProgress = false
			saveEventsQueue()
		}
	}
	
	let analyticsClient = AnalyticsClientImpl()
	let eventsDAO: EventsDAO
	var eventsQueue = [Event]()
	let flushInterval: Int
	var isInProgress = false
	let userDAO: UserDAO
}
