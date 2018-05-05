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
import RxCocoa
import RxSwift
import liferay_analytics_ios
import UIKit
import NSObject_Rx

/**
- Author: Allan Melo
*/
public class Forms {

	/**
		Send form submitted event to Liferay Analytics
	
		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func formSubmitted(attributes: FormAttributes) {
		let eventId = EventType.formSubmitted.rawValue
		
		Analytics.send(
			eventId: eventId,
			applicationId: Forms.APPLICATION_ID,
			properties: ["formId": attributes.formId]
		)
	}
	
	static let APPLICATION_ID = "forms"
}
