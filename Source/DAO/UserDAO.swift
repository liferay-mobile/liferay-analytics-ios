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
	
	func clearSession() {
		do {
			try fileStorage.setString(key: STORAGE_KEY_USER_ID, value: "")
			try fileStorage.setString(key: USER_CONTEXT, value: "")
		}
		catch let error {
			print("Could not clear session: \(error.localizedDescription)")
		}
	}
	
	func getUserContext() -> IdentityContextMessage? {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard
			let userContextJson = fileStorage.getString(key: USER_CONTEXT),
			let data = userContextJson.data(using: .utf8) else {
				return nil
		}
		
		do {
			return try decoder.decode(IdentityContextMessage.self, from: data)
		}
		catch {
			return nil
		}
	}
	
	func getUserId() -> String? {
		return fileStorage.getString(key: STORAGE_KEY_USER_ID)
	}
	
	func setUserId(userId: String) {
		do {
			try fileStorage.setString(key: STORAGE_KEY_USER_ID, value: userId)
		}
		catch let error {
			print("Could not save userId: \(error.localizedDescription)")
		}
	}
	
	func setUserContext(identity: IdentityContextMessage) {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		
		do {
			let userContext = try encoder.encode(identity)
			
			guard let json = String(data: userContext, encoding: .utf8) else {
				return
			}
			
			try fileStorage.setString(key: USER_CONTEXT, value: json)
		}
		catch let error {
			print("Could not save identity context: \(error.localizedDescription)")
		}
	}
	
	let fileStorage: FileStorage
	internal let STORAGE_KEY_USER_ID = "lcs_client_user_id"
	internal let USER_CONTEXT = "user_context"
}
