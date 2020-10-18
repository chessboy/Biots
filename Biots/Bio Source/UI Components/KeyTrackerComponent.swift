//
//  KeyTrackerComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class KeyTrackerComponent: OKComponent {
	
	var keyCodesDown = [UInt16]()
	var shiftDown: Bool = false
	var commandDown: Bool = false
	var optionDown: Bool = false

	func keyDown(keyCode: UInt16, shiftDown: Bool = false, commandDown: Bool = false, optionDown: Bool = false) {
		
		self.shiftDown = shiftDown
		self.commandDown = commandDown
		
		if !isKeyDown(keyCode: keyCode) {
			keyCodesDown.append(keyCode)
		}
		//print("keyDown: \(keyCodesDown)")
	}

	func keyUp(keyCode: UInt16, shiftDown: Bool = false, commandDown: Bool = false, optionDown: Bool = false) {
		keyCodesDown = keyCodesDown.filter({ $0 != keyCode })
		//print("keyUp: \(keyCodesDown)")
	}

	func isKeyDown(keyCode: UInt16) -> Bool {
		return keyCodesDown.filter({ $0 == keyCode }).first != nil
	}

	func clearKeysDown() {
		keyCodesDown.removeAll()
		shiftDown = false
		commandDown = false
		optionDown = false
		//print("clearKeysDown: \(keyCodesDown)")
	}
}

