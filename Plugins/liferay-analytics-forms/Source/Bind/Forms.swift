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
		
		send(eventId: eventId, properties: ["formId": attributes.formId])
	}
	
	/**
		Send form viewed event to Liferay Analytics
	
		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func formViewed(attributes: FormAttributes) {
		let eventId = EventType.formViewed.rawValue
		
		send(
			eventId: eventId,
			properties: ["formId": attributes.formId,
						 "title" : attributes.formTitle ?? ""]
		)
	}
	
	/**
		Track all events of the field and send to Liferay Analytics

		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func trackField(field: UITextField, fieldAttributes: FieldAttributes) {
		let observableFocus = field
			.rx
			.controlEvent(UIControl.Event.editingDidBegin)
			.asObservable()
		
		let observableBlur = field
			.rx
			.controlEvent(UIControl.Event.editingDidEnd)
			.asObservable()
		
		trackField(
			observableFocus: observableFocus, observableBlur: observableBlur,
			disposeBag: field.rx.disposeBag, fieldAttributes: fieldAttributes)
	}

	/**
		Track all events of the field and send to Liferay Analytics
	
		- Throws: `AnalyticsError.analyticsNotInitialized`
		if the Analytics library is not initialized.
	*/
	public class func trackField(field: UITextView, fieldAttributes: FieldAttributes) {
		let observableFocus = field
			.rx
			.didBeginEditing
			.asObservable()
		
		let observableBlur = field
			.rx
			.didEndEditing
			.asObservable()
		
		trackField(
			observableFocus: observableFocus, observableBlur: observableBlur,
			disposeBag: field.rx.disposeBag, fieldAttributes: fieldAttributes)
	}
	
	class func fieldBlurred(fieldAttributes: FieldAttributes, focusDuration: Int) {
		let eventId = EventType.fieldBlurred.rawValue
		
		send(
			eventId: eventId,
			properties: ["fieldName": fieldAttributes.name,
						"title": fieldAttributes.title ?? "",
						"formId": fieldAttributes.formAttributes.formId,
						"focusDuration": String(focusDuration)]
		)
	}
	
	class func fieldFocused(fieldAttributes: FieldAttributes) {
		let eventId = EventType.fieldFocused.rawValue
		
		send(
			eventId: eventId,
			properties: ["fieldName": fieldAttributes.name,
						"title": fieldAttributes.title ?? "",
						"formId": fieldAttributes.formAttributes.formId]
		)
	}
	
	class func send(eventId: String, properties: [String: String]? = nil) {
		Analytics.send(
			eventId: eventId, applicationId: Forms.APPLICATION_ID, properties: properties)
	}
	
	class func trackField(
		observableFocus: Observable<()>, observableBlur: Observable<()>, disposeBag: DisposeBag,
		fieldAttributes: FieldAttributes) {
		
		let observableFocus = observableFocus
			.do(onNext: { _ in
				self.fieldFocused(fieldAttributes: fieldAttributes)
			})
			.map { _ in
				return Date()
			}

		observableBlur.withLatestFrom(observableFocus)
			.subscribe({ event in
				guard let focusedDate = event.element else {
					return
				}
				
				let currentDate = Date()
				let focusDuration =
					Int(currentDate.timeIntervalSince1970 - focusedDate.timeIntervalSince1970)
				
				self.fieldBlurred(fieldAttributes: fieldAttributes, focusDuration: focusDuration)
			})
			.disposed(by: disposeBag)
	}

	static let APPLICATION_ID = "Forms"
}
