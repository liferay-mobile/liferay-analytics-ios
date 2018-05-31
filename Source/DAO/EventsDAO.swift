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

internal class EventsDAO {

    init(fileStorage: FileStorage) {
		self.fileStorage = fileStorage
	}

	func addEvents(userId: String, events: [Event]) {
		var currentEvents = getEvents()
		currentEvents[userId] = (currentEvents[userId] ?? []) + events
		
		replaceEvents(events: currentEvents)
	}
	
	func getEvents() -> [String: [Event]] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard let data = fileStorage.getData(key: STORAGE_KEY_EVENTS) else {
			return [:]
		}
		
		do {
			return try decoder.decode([String: [Event]].self, from: data)
		}
		catch {
			replaceEvents(events: [:])
			
			return [:]
		}
	}
	
	func replaceEvents(events: [String: [Event]]) {
		do {
			let encoder = JSONEncoder()
			encoder.dateEncodingStrategy = .iso8601
			let newEventsData = try encoder.encode(events)
			
			guard let json = String(data: newEventsData, encoding: .utf8) else {
				throw AnalyticsError.couldNotParseEvents
			}
			
			try fileStorage.setString(key: STORAGE_KEY_EVENTS, value: json)
		}
		catch let error {
			print("Could not replace events: \(error.localizedDescription)")
		}
	}
	
	func updateEvents(userId: String, events: [Event]) {
		var userIdsEvents = getEvents()
		userIdsEvents[userId] = events
		
		replaceEvents(events: userIdsEvents)
	}
	
	let fileStorage: FileStorage
	let STORAGE_KEY_EVENTS = "lcs_client_batch"
}
