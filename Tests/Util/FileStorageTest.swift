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
class FileStorageTest: XCTestCase {
	
	override func setUp() {
		_fileStorage = try! FileStorage()
	}
	
	func testSetString() {
		let key = "myKey"
		let value = "value1"
		try! _fileStorage.setString(key: key, value: value)
		
		let result = _fileStorage.getString(key: key)
		XCTAssertEqual(result, value)
	}
	
	func testUnavailableFile() {
		let result = _fileStorage.getString(key: "unavailable")
		
		XCTAssertEqual(result, nil)
	}
	
	var _fileStorage: FileStorage!
}

