//
//  ConfigParam.swift
//  Biots
//
//  Created by Rob Silverman on 11/26/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation

struct ConfigParam: CustomStringConvertible {
	var start: CGFloat
	var end: CGFloat
	
	func valueForGeneration(_ generation: Int, generationThreshold: Int) -> CGFloat {
		
		if generation >= generationThreshold {
			return end
		}
		
		let percentage = generation.cgFloat / generationThreshold.cgFloat
		return start + percentage * (end-start)
	}
	
	var description: String {
		return "{start: \(start), end: \(end)}"
	}
}

func * (param: ConfigParam, scalar: CGFloat) -> ConfigParam {
	return ConfigParam(start: param.start * scalar, end: param.end * scalar)
}

func *= (param: inout ConfigParam, scalar: CGFloat) {
	param = param * scalar
}

func / (left: ConfigParam, right: ConfigParam) -> ConfigParam {
	return ConfigParam(start: left.start / right.start, end: left.end / right.end)
}

func /= (left: inout ConfigParam, right: ConfigParam) {
	left = left / right
}
