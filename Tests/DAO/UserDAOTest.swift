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
class UserDAOTest: XCTestCase {
	
	override func setUp() {
		let fileStorage = try! FileStorage()
		
		userDAO = UserDAO(fileStorage: fileStorage)
		userDAO.clearSession()
		userDAO.replaceUserContexts(identities: [])
	}
	
	override func tearDown() {
		userDAO.clearSession()
	}
	
	func testAddUserContext() {
		let identityContext = IdentityContext(analyticsKey: "key1")
		
		userDAO.addUserContext(identity: identityContext)
		let persistedIdentityContext = userDAO.getUserContexts().last
		assert(userDAO.getUserContexts().count == 1)
		assert(persistedIdentityContext?.analyticsKey == "key1")
		
		let identityContext2 = IdentityContext(analyticsKey: "key2")
		userDAO.addUserContext(identity: identityContext2)
		assert(userDAO.getUserContexts().count == 2)
		assert(userDAO.getUserContexts().last?.analyticsKey == "key2")
	}
	
	func testClearSession() {
		userDAO.setUserId(userId: "userId1")
		userDAO.clearSession()
		
		let userId = userDAO.getUserId()
		
		assert(userId == "")
	}
	
	func testReplaceUserContext() {
		let identityContext1 = IdentityContext(analyticsKey: "key1")
		userDAO.addUserContext(identity: identityContext1)
		let identityContext2 = IdentityContext(analyticsKey: "key2")
		userDAO.addUserContext(identity: identityContext2)
		
		let identityContext = IdentityContext(analyticsKey: "key123")
		userDAO.replaceUserContexts(identities: [identityContext])
		
		assert(userDAO.getUserContexts().count == 1)
		assert(userDAO.getUserContexts().last?.analyticsKey == "key123")
	}
	
	func testSetUserId() {
		userDAO.setUserId(userId: "userId1")
		let userId = userDAO.getUserId()
		
		assert(userId == "userId1")
	}
	
	var userDAO: UserDAO!
}
