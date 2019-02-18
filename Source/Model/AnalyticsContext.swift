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
import UIKit

/**
- Author: Marcelo Mello
*/
internal class AnalyticsContext: Codable {
	
	init() {
		var settings: [String: AnyObject]?
		
		if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
			settings = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
		}

		self.languageId = Locale.preferredLanguages.first
		self.screenHeight = UIScreen.main.bounds.height
		self.screenWidth = UIScreen.main.bounds.width

		if let userAgentString = UIWebView(frame: CGRect.zero).stringByEvaluatingJavaScript(from: "navigator.userAgent") {
			self.userAgent = userAgentString
		}
		
		if let applicationName = settings?["CFBundleName"] as? String,
			let applicationVersion = settings?["CFBundleVersion"] as? String {
				self.userAgent?.append(" " + applicationName + "/" + applicationVersion)
		}
	}
	
	var languageId: String?
	let screenHeight: CGFloat
	let screenWidth: CGFloat
	var userAgent: String?
}
