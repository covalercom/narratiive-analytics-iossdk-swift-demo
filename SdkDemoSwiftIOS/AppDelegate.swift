//
//  AppDelegate.swift
//  SdkDemoSwiftIOS
//
//  Created by David Lin on 21/6/20.
//  Copyright © 2020 Narratiive Audience Measurement. All rights reserved.
//

import UIKit
import NarratiiveSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        guard let sdk = NarratiiveSDK.sharedInstance() else {
          assert(false, "Narratiive SDK not configured correctly")
        }

        // Optional, out put debug information when `true`
        // Remove before app release.
        sdk.debugMode = true
        // Optional, use of IDFA to identify user
        sdk.useIDFA = true
            
        sdk.setup(withHost: "m-example.org", andHostKey: "9SN/cN6oEv9QO2WCE7sb2D+BLmM=")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

