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
extension URLSession {
	
	class func sendPost(url: URL, body: Data) -> (Data?, URLResponse?, Error?) {
		var urlRequest = URLRequest(url: url)
		
		urlRequest.httpBody = body
		urlRequest.httpMethod = "POST"
		urlRequest.setValue(
			"application/json; charset=utf-8",
			forHTTPHeaderField: "Content-Type")
		
		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		
		return session.sendSynchronousRequest(request: urlRequest)
	}
	
	func sendSynchronousRequest(request: URLRequest)
		-> (Data?, URLResponse?, Error?) {
			
		var result: (Data?, URLResponse?, Error?)
			
		let semaphore = DispatchSemaphore(value: 0)
		dataTask(with: request) { data, response, error in
			result = (data, response, error)
			
			semaphore.signal()
		}.resume()
		
		_ = semaphore.wait(timeout: .distantFuture)
		
		return result
	}
}
