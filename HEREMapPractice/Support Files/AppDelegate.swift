//
//  AppDelegate.swift
//  HEREMapPractice
//
//  Created by Mark on 4/10/18.
//  Copyright © 2018 hungryfool. All rights reserved.
//

import UIKit
import NMAKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		NMAApplicationContext.setAppId(Credentials.MapAppID,
									   appCode: Credentials.MapAppCode,
									   licenseKey: Credentials.MapLicenseKey)
		
		window = UIWindow(frame: UIScreen.main.bounds)
		
		window?.rootViewController = MapViewController()
		
		window?.makeKeyAndVisible()
		
		return true
	}
}

