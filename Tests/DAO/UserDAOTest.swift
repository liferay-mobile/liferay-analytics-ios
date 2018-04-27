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

@testable import com_liferay_analytics_client
import XCTest

/**
* @author Allan Melo
*/
class UserDAOTest: XCTestCase {
	
	override func setUp() {
		let fileStorage = try! FileStorage()
		
		userDAO = UserDAO(fileStorage: fileStorage)
		userDAO.clearSession()
	}
	
	override func tearDown() {
		userDAO.clearSession()
	}
	
	func testSetUserContext() {
		let identityContext = IdentityContextMessage(analyticsKey: "key1") {
			$0.userId = "userId1"
		}
		
		userDAO.setUserContext(identity: identityContext)
		let persistedIdentityContext = userDAO.getUserContext()
		assert(persistedIdentityContext?.analyticsKey == "key1")
		assert(persistedIdentityContext?.userId == "userId1")
	}
	
	func testSetUserId() {
		userDAO.setUserId(userId: "userId1")
		let userId = userDAO.getUserId()
		
		assert(userId == "userId1")
	}
	
	var userDAO: UserDAO!
}
