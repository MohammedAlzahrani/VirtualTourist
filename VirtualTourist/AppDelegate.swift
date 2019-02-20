//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Mohammed ALZAHRANI on 08/02/2019.
//  Copyright © 2019 Mohammed ALZAHRANI. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(model: "VirtualTourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        let navVC = window?.rootViewController as! UINavigationController
        let mapVC = navVC.topViewController as! MapViewController
        mapVC.dataController = dataController
        return true
    }

}

