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

internal class UserDAO {
	
	init(fileStorage: FileStorage) {
		self.fileStorage = fileStorage
	}
	
	func addUserContext(identity: IdentityContext) {
		let currentUserContexts = getUserContexts()
		let newUserContexts = currentUserContexts + [identity]
		
		replaceUserContexts(identities: newUserContexts)
	}
	
	func clearSession() {
		do {
			try fileStorage.setString(key: STORAGE_KEY_USER_ID, value: "")
		}
		catch let error {
			print("Could not clear session: \(error.localizedDescription)")
		}
	}
	
	func getUserContexts() -> [IdentityContext] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard let data = fileStorage.getData(key: USER_CONTEXTS) else {
			return []
		}
		
		do {
			return try decoder.decode([IdentityContext].self, from: data)
		}
		catch {
			replaceUserContexts(identities: [])
			
			return []
		}
	}
	
	func getUserId() -> String? {
		return fileStorage.getString(key: STORAGE_KEY_USER_ID)
	}
	
	func replaceUserContexts(identities: [IdentityContext]) {
		do {
			let encoder = JSONEncoder()
			encoder.dateEncodingStrategy = .iso8601
			let newUserContextsData = try encoder.encode(identities)
			
			guard let json = String(data: newUserContextsData, encoding: .utf8) else {
				try fileStorage.setString(key: USER_CONTEXTS, value: "")
				
				return
			}
			
			try fileStorage.setString(key: USER_CONTEXTS, value: json)
		}
		catch let error {
			print("Could not replace events: \(error.localizedDescription)")
		}
	}
	
	func setUserId(userId: String) {
		do {
			try fileStorage.setString(key: STORAGE_KEY_USER_ID, value: userId)
		}
		catch let error {
			print("Could not save userId: \(error.localizedDescription)")
		}
	}
	
	let fileStorage: FileStorage
	internal let STORAGE_KEY_USER_ID = "lcs_client_user_id"
	internal let USER_CONTEXTS = "user_contexts"
}
