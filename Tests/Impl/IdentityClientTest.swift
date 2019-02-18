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
import Mockingjay
import XCTest

/**
* @author Allan Melo
*/
class IdentityClientTest: XCTestCase {
	func testSendIdentityContext() {
		do {
			try Analytics.init()
			let instance = try Analytics.getInstance()
			
			let result = ["status": "success"]
			stub(http(.post, uri: instance.endpointURL + "/identity"), json(result))
            
			let identityContext = IdentityContext(dataSourceId: instance.dataSourceId) {
				$0.language = "en-US"
				$0.identity = Identity(name: "Joe Bloggs", email: "joe.blogs@liferay.com")
			}
            
			try _identityClient.send(endpointURL: instance.endpointURL, identityContext: identityContext)
		}
		catch {
			assertionFailure()
		}
	}
	
	let _identityClient = IdentityClient()
}
