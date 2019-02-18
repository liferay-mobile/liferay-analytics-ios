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
		let identityContext = IdentityContext(dataSourceId: "key1")
		
		userDAO.addUserContext(identity: identityContext)
		let persistedIdentityContext = userDAO.getUserContexts().last
		XCTAssertEqual(userDAO.getUserContexts().count, 1)
		XCTAssertEqual(persistedIdentityContext?.dataSourceId, "key1")
		
		let identityContext2 = IdentityContext(dataSourceId: "key2")
		userDAO.addUserContext(identity: identityContext2)
		
		XCTAssertEqual(userDAO.getUserContexts().count, 2)
		XCTAssertEqual(userDAO.getUserContexts().last?.dataSourceId, "key2")
	}
	
	func testClearSession() {
		userDAO.setUserId(userId: "userId1")
		userDAO.clearSession()
		
		let userId = userDAO.getUserId()
		
		XCTAssertEqual(userId, "")
	}
	
	func testReplaceUserContext() {
		let identityContext1 = IdentityContext(dataSourceId: "key1")
		userDAO.addUserContext(identity: identityContext1)
		let identityContext2 = IdentityContext(dataSourceId: "key2")
		userDAO.addUserContext(identity: identityContext2)
		
		let identityContext = IdentityContext(dataSourceId: "key123")
		userDAO.replaceUserContexts(identities: [identityContext])
		
		XCTAssertEqual(userDAO.getUserContexts().count, 1)
		XCTAssertEqual(userDAO.getUserContexts().last?.dataSourceId, "key123")
	}
	
	func testSetUserId() {
		userDAO.setUserId(userId: "userId1")
		let userId = userDAO.getUserId()
		
		XCTAssertEqual(userId, "userId1")
	}
	
	var userDAO: UserDAO!
}
