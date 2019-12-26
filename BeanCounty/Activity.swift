//
//  Activity.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import UIKit

enum Activity: String {
  case list
  case settings

  var type: String {
    "com.dsignal.BeanCounty.\(rawValue)"
  }

  var userActivity: NSUserActivity {
    NSUserActivity(activityType: type)
  }
}
