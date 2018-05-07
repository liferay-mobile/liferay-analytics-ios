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
- Author: Allan Melo
*/
public class Analytics {
	
	public static let DEFAUL_TIME_INTERVAL = 60
	
	private init(
		analyticsKey: String, flushInterval: Int, fileStorage: FileStorage) {
		
		self.analyticsKey = analyticsKey
		
		self.userDAO = UserDAO(fileStorage: fileStorage)
		self.flushProcess = FlushProcess(fileStorage: fileStorage, flushInterval: flushInterval)
	}
	
	/**
		Need to call to clear the identity, to send events with anonymous session again.
		Recommended after the user logout of application.
	
		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func clearSession() {
		let instance = try! Analytics.getInstance()
		
		instance.userDAO.clearSession()
	}
	
	/**
		Need to call method to initialize the library
		
		- Throws: `AnalyticsError.analyticsAlreadyInitialized` if the Analytics
		library is already initialized.
	*/
	public class func configure(
		analyticsKey: String, flushInterval: Int = Analytics.DEFAUL_TIME_INTERVAL) throws {
		
		if let _ = sharedInstance {
			throw AnalyticsError.analyticsAlreadyInitialized
		}
		
		let fileStorage = try FileStorage()
		
		sharedInstance = Analytics(
			analyticsKey: analyticsKey, flushInterval: flushInterval, fileStorage: fileStorage)
	}
	
	/**
		Need to call to send events with user informations.
		Recommended after the user login in application.
	
		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func setIdentity(email: String, name: String? = nil) {
		let instance = try! Analytics.getInstance()
		
		let identityContext = instance.getDefaultIdentityContext()
		
		identityContext.identityFields["email"] = email
		identityContext.identityFields["name"] = name

		clearSession()
		instance.userDAO.setUserContext(identity: identityContext)
	}
	
	/**
		Send custom events to Analytics
	
		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func send(
		eventId: String, applicationId: String, properties: [String: String]? = nil) {
		
		let instance = try! Analytics.getInstance()
		
		instance.createEvent(eventId: eventId, applicationId: applicationId, properties: properties)
	}
	
	func getDefaultIdentityContext() -> IdentityContextMessage {
		return IdentityContextMessage(analyticsKey: analyticsKey) {
			$0.touchSupport = true
			$0.platform = "iOS"
			
			if let language = Locale.preferredLanguages.first {
				$0.language = language
			}
		}
	}
	
	class func getInstance() throws -> Analytics {
		guard let sharedInstance = Analytics.sharedInstance else {
			throw AnalyticsError.analyticsNotInitialized
		}
		
		return sharedInstance
	}
	
	func createEvent(eventId: String, applicationId: String, properties: [String: String]? = nil) {
		let event = Event(applicationId: applicationId, eventId: eventId) {
			if let properties = properties {
				$0.properties = properties
			}
		}
		
		flushProcess.addEvent(event: event)
	}
	
	internal static var sharedInstance: Analytics?
	
	internal let analyticsKey: String
	internal let flushProcess: FlushProcess
	internal let userDAO: UserDAO
}
