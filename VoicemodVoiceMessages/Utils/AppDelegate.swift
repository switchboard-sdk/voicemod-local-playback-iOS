//
//  AppDelegate.swift
//  VoicemodVoiceMessages
//
//  Created by Banto Balazs on 11/06/2024.
//

import UIKit
import SwitchboardSDK
import SwitchboardVoicemod
import SwitchboardRNNoise

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SBSwitchboardSDK.initialize(withAppID: switchboardClientID, appSecret: switchboardClientSecret)
        SBVoicemodExtension.initialize(withClientKey: voicemodClientKey, pathToVoiceData: Bundle.main.bundlePath.appending("/VoiceData"))
        SBRNNoiseExtension.initialize()
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

