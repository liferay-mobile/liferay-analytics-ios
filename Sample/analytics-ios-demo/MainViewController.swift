//
//  MainViewController.swift
//  analytics-ios-demo
//
//  Created by Allan Melo on 05/05/18.
//  Copyright © 2018 Allan Melo. All rights reserved.
//

import liferay_analytics_ios
import UIKit

class MainViewController: UIViewController {

	override func viewDidLoad() {
		Analytics.send(eventId: "PageView", applicationId: "MYSAMPLE")
	}
}
