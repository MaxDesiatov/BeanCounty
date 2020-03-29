//
//  AppDelegate.swift
//  BeanCounty
//
//  Created by Max Desiatov on 11/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import UIKit

enum StoreKey: String {
  case transferWise
  case freeAgent
}

let keychainService = "com.dsignal.BeanCounty"

let appDelegate = UIApplication.shared.delegate as? AppDelegate

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  let transferWise = TransferWiseStore()
  let freeAgent = FreeAgentStore()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Override point for customization after application launch.
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.

    let name = options.userActivities.contains { $0.activityType == Activity.settings.type } ?
      "Settings" : "Default Configuration"

    connectingSceneSession.userInfo?[StoreKey.transferWise.rawValue] = transferWise
    connectingSceneSession.userInfo?[StoreKey.freeAgent.rawValue] = freeAgent

    return UISceneConfiguration(name: name, sessionRole: connectingSceneSession.role)
  }

  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called
    // shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as
    // they will not return.
  }
}
