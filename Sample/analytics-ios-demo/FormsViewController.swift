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

import UIKit
import liferay_analytics_forms_ios

/**
- Author: Allan Melo
*/
class FormsViewController: UIViewController {
	@IBOutlet weak var ageField: UITextField!
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var moreTextView: UITextView!
	
	@IBAction func formSubmitted(_ sender: Any) {
		Forms.formSubmitted(attributes: formAttributes)
	}
	
	override func viewDidLoad() {
		Forms.formViewed(attributes: formAttributes)

		let fieldAgeAttributes = FieldAttributes(
			name: "ageField", title: "Age", formAttributes: formAttributes)

		Forms.trackField(field: ageField, fieldAttributes: fieldAgeAttributes)

		let fieldNameAttributes = FieldAttributes(
			name: "nameField", formAttributes: formAttributes)

		Forms.trackField(field: nameField, fieldAttributes: fieldNameAttributes)
		
		let fieldMoreAttributes = FieldAttributes(
			name: "moreTextView", formAttributes: formAttributes)
		
		Forms.trackField(field: moreTextView, fieldAttributes: fieldMoreAttributes)
	}
	
	let formAttributes = FormAttributes(formId: "10", formTitle: "People")
}
