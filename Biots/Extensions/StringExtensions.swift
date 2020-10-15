//
//  StringExtensions.swift
//  Biots
//
//  Created by Robert Silverman on 4/18/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

extension String {
	
	func truncated(_ length: Int, trailing: String = "…") -> String {
		return (self.count > length) ? self.prefix(length) + trailing : self
	}
	//https://stackoverflow.com/questions/42192289/is-there-a-built-in-swift-function-to-pad-strings-at-the-beginning
	func padding(leftTo paddedLength:Int, withPad pad:String=" ", startingAt padStart:Int=0) -> String {
		let rightPadded = self.padding(toLength:max(count,paddedLength), withPad:pad, startingAt:padStart)
		return "".padding(toLength:paddedLength, withPad:rightPadded, startingAt:count % paddedLength)
	}

	func padding(rightTo paddedLength:Int, withPad pad:String=" ", startingAt padStart:Int=0) -> String {
		return self.padding(toLength:paddedLength, withPad:pad, startingAt:padStart)
	}

	func padding(sidesTo paddedLength:Int, withPad pad:String=" ", startingAt padStart:Int=0) -> String {
		let rightPadded = self.padding(toLength:max(count,paddedLength), withPad:pad, startingAt:padStart)
		return "".padding(toLength:paddedLength, withPad:rightPadded, startingAt:(paddedLength+count)/2 % paddedLength)
	}
}
