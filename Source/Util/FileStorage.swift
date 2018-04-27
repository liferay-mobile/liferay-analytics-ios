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
internal class FileStorage {
	
	init() throws {
		guard let folderUrl = FileStorage.getApplicationSupportDirectoryURL()
			else {
				
			throw FileStorageError.cacheDirectoryUnavailable
		}
		
		self.folderURL = folderUrl
		try createDirectoryAtURLIfNeeded()
	}
	
	func createDirectoryAtURLIfNeeded() throws {
		let fileManager = FileManager.default
		
		let exist = fileManager.fileExists(
			atPath: folderURL.path, isDirectory: nil)
		
		if (!exist) {
			try fileManager.createDirectory(
				atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
		}
	}
	
	class func getApplicationSupportDirectoryURL() -> URL? {
		let paths = NSSearchPathForDirectoriesInDomains(
			.applicationSupportDirectory, .userDomainMask, true)
		
		guard let supportPath = paths.first else {
			
			return nil
		}
		
		return URL.init(fileURLWithPath: supportPath)
	}
	
	func getString(key: String) -> String? {
		let url = urlForKey(key)
		
		guard let data = NSData(contentsOfFile: url.path) as Data? else {
			return nil
		}
		
		return String(data: data, encoding: .utf8)
	}
	
	func setString(key: String, value: String) throws {
		let data = value.data(using: .utf8)
		
		let url = urlForKey(key)
		try data?.write(to: url)
	}
	
	func urlForKey(_ key: String) -> URL {
		return folderURL.appendingPathComponent(key)
	}
	
	let folderURL: URL
}
