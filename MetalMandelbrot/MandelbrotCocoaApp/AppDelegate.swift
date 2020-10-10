//
//  AppDelegate.swift
//  MandelbrotCocoaApp
//
//  Created by Felix Naredi on 2020-10-10.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var controller: ViewController!
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true, block: { _ in
      DispatchQueue.main.async { self.controller.step() }
    })
  }
}
