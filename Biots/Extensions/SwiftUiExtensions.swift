//
//  SwiftUiExtensions.swift
//  Biots
//
//  Created by Robert Silverman on 10/21/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import SwiftUI
import SpriteKit

extension SKColor {
	var color: Color {
		return Color(.sRGB, red: Double(redComponent), green: Double(greenComponent), blue: Double(blueComponent), opacity: Double(alphaComponent))
	}
}
