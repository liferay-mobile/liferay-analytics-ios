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
	
	private init(endpointURL: String, dataSourceId: String,
                 fileStorage: FileStorage, flushInterval: Int) {

		self.endpointURL = endpointURL
		self.dataSourceId = dataSourceId
        
		self.userDAO = UserDAO(fileStorage: fileStorage)
		self.flushProcess = FlushProcess(endpointURL: endpointURL, fileStorage: fileStorage, flushInterval: flushInterval)
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
		- Throws: `AnalyticsError.dataSourceIdNullOrEmpty` if com.liferay.analytics.DataSourceId
		wasn't filled.
		- Throws: `AnalyticsError.invalidEndpointURL` if com.liferay.analytics.DataSourceId
		wasn't filled or value don't is a valid URL.
		- Throws: `AnalyticsError.invalidFlushIntervalValue` if flushInterval be less then 1.
	*/
	public class func `init`(flushInterval: Int = Analytics.DEFAUL_TIME_INTERVAL) throws {
        
		if let _ = sharedInstance {
			throw AnalyticsError.analyticsAlreadyInitialized
		}

		let fileStorage = try FileStorage()
		
		var settings: [String: AnyObject]?
		
		#if DEBUG
			let bundle = Bundle(for: self)
		#else
		    let bundle = Bundle.main
		#endif
		
		if let path = bundle.path(forResource: "Info", ofType:"plist") {
			settings = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
		}

		guard let dataSourceId = settings?["com.liferay.analytics.DataSourceId"] as? String else {
			throw AnalyticsError.dataSourceIdNullOrEmpty
		}

		guard let endpointURL = settings?["com.liferay.analytics.EndpointUrl"] as? String,
			let _ = URL(string: endpointURL) else {
				
			throw AnalyticsError.invalidEndpointURL
		}

		if (flushInterval <= 0) {
			throw AnalyticsError.invalidFlushIntervalValue
		}
        
		sharedInstance = Analytics(endpointURL: endpointURL, dataSourceId: dataSourceId,
                                   fileStorage: fileStorage, flushInterval: flushInterval)
	}
	
	/**
		Need to call to send events with user informations.
		Recommended after the user login in application.
	
		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func setIdentity(email: String, name: String = "") {
		let instance = try! Analytics.getInstance()
		let identityContext = instance.getDefaultIdentityContext()
		
		let identity = Identity(name: name, email: email)
		identityContext.identity = identity

		instance.userDAO.addUserContext(identity: identityContext)
		instance.userDAO.setUserId(userId: identityContext.userId)
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
	
	func getDefaultIdentityContext() -> IdentityContext {
		let instance = try! Analytics.getInstance()

		return IdentityContext(dataSourceId: instance.dataSourceId) {
			if let language = Locale.preferredLanguages.first {
				$0.language = language
			}
		}
	}
	
	class func getInstance() throws -> Analytics {
		guard let instance = Analytics.sharedInstance else {
			throw AnalyticsError.analyticsNotInitialized
		}
		
		return instance
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
	
	internal let endpointURL: String
	internal let dataSourceId: String
	internal let flushProcess: FlushProcess
	internal let userDAO: UserDAO
}
