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
class IdentityClientTest: XCTestCase {
	func testSendIdentityContext() {
		let identityContext = IdentityContext(analyticsKey: "liferay.com") {
				$0.language = "en-US"
				$0.identity = Identity(name: "Joe Bloggs", email: "joe.blogs@liferay.com")
		}
		
		do {
			try _identityClient.send(identityContext: identityContext)
		}
		catch {
			assertionFailure()
		}
	}
	
	let _identityClient = IdentityClient()
}
