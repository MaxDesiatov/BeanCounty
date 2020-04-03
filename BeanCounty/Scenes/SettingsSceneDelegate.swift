//
//  SettingsSceneDelegate.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import OAuthSwift
import SwiftUI
import UIKit

final class SettingsSceneDelegate: NSObject, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard
      let transferWise = appDelegate?.transferWise,
      let freeAgent = appDelegate?.freeAgent
    else { return }

    let view = SettingsView(twStore: transferWise, faStore: freeAgent)

    // Use a UIHostingController as window root view controller.
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: view)
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url, url.host == "oauth-callback" else {
      return
    }

    OAuthSwift.handle(url: url)
  }
}
