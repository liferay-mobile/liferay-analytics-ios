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

/**
* @author Allan Melo
*/
public class IdentityContextMessage: Codable {

	init(analyticsKey: String, build: (IdentityContextMessage) -> Void) {
		self.analyticsKey = analyticsKey
		
		build(self)
	}

	internal let analyticsKey: String
	internal var browserPluginDetails: String?
	internal var canvasFingerPrint: String?
	internal var cookiesEnabled = false
	internal var dataSourceIdentifier: String?
	internal var dataSourceIndividualIdentifier: String?
	internal var domain: String?
	internal var httpAcceptHeaders: String?
	internal var identityFields = [String: String]()
	internal var language: String?
	internal var platform: String?
	internal var protocolVersion: String?
	internal var screenSizeAndColorDepth: String?
	internal var systemFonts: String?
	internal var timezone: String?
	internal var touchSupport = false
	internal var userAgent: String?
	internal var userId: String?
	internal var webGLFingerPrint: String?
}
