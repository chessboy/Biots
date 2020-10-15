//
//  AppDelegate.swift
//  Biots
//
//  Created by Robert Silverman on 4/11/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Cocoa
import SwiftUI
import OctopusKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var window: NSWindow!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
				
		// Create the SwiftUI view that provides the window contents.
		let contentView = ContentView()

		OctopusKit.logForDeinits.disabled = true
		OctopusKit.logForDebug.disabled = true
		OctopusKit.logForStates.disabled = true
		OctopusKit.logForFramework.disabled = true
		OctopusKit.logForComponents.disabled = true

		// Create the window and set the content view. 
		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered, defer: false)
		window.center()
		window.setFrameAutosaveName("Main Window")
		window.contentView = NSHostingView(rootView: contentView)
		window.makeKeyAndOrderFront(nil)
	}
	
	func applicationDidResignActive(_ notification: Notification) {
		//print("applicationDidResignActive")
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		//print("applicationWillTerminate")
	}
}

