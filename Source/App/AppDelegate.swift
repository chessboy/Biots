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

		OKLog.printTextOnSecondLine = true
		
		OctopusKit.logForDeinits.disabled = true
		OctopusKit.logForDebug.disabled = true
		OctopusKit.logForStates.disabled = true
		OctopusKit.logForFramework.disabled = true
		OctopusKit.logForComponents.disabled = true

		guard let screen = NSScreen.main else {
			OctopusKit.logForErrors.add("could not get main screen bounds")
			return
		}
		
		let width = screen.frame.size.width
		let height = screen.frame.size.height
		
		// Create the window and set the content view. 
		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: width, height: height),
			styleMask: [.titled, .resizable],
			backing: .buffered, defer: false)
		window.toggleFullScreen(self)
		window.contentView = NSHostingView(rootView: contentView)
		window.makeKeyAndOrderFront(nil)
		window.enableCursorRects()
		
		let _ = DataManager.shared
	}
	
	func applicationDidResignActive(_ notification: Notification) {
		//print("applicationDidResignActive")
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		//print("applicationWillTerminate")
	}
}

