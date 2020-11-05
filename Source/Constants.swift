//
//  Constants.swift
//  Biots
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

struct Constants {
		
	struct Env {
				
		static let windowWidth: CGFloat = 2400

		static let filenameSaveStateDebug = "Debug"
		static let filenameSaveStateSave = "Save"
		static let filenameSaveStateEvolved = "Evolved"
		
		static let gridBlockSize: CGFloat = 400
		static let selfReplicationMaxSpawn = 3
		static let unbornGenomeCacheCount = 40
		static let showSpriteKitStats = true
		
		static let simpleGraphics = Graphics(isAntialiased: false, blendMode: .replace, shadows: false, showGrid: false)
		static let niceGraphics = Graphics(isAntialiased: true, blendMode: .alpha, shadows: true, showGrid: true)
		static let niceGraphicsNoShadows = Graphics(isAntialiased: false, blendMode: .alpha, shadows: false, showGrid: true)
		static let graphics = niceGraphics
	}
		
	struct Biot {
		static let radius: CGFloat = 40
		static let adjustBodyColor = false
		
		enum StatsLine: Int { case line1, line2, line3 }

		struct Stats {
			static let maxLinesOfText = 3
			
			static let labelAttrs: [AttributedStringBuilder.Attribute] = [
				.textColor(UIColor.lightGray),
				.font(UIFont.systemFont(ofSize: 42, weight: .bold))
			]
			
			static let valueAttrs: [AttributedStringBuilder.Attribute] = [
				.textColor(UIColor.white),
				.font(UIFont(name: Constants.Font.regular, size: 72)!)
			]
			
			static let iconAttrs: [AttributedStringBuilder.Attribute] = [
				.font(UIFont.systemFont(ofSize: 66, weight: .bold))
			]
		}
	}
	
	struct Algae {
		static let radius: CGFloat = 16
		static let bite: CGFloat = 25
		static let timeBetweenBites: TimeInterval = 3 // seconds between eating the same algae
	}
	
	struct Water {
		static let sip: CGFloat = 20
		static let timeBetweenSips: TimeInterval = 1.5 // seconds between drinking from the same water source
	}
	
	struct Resource {
		static let minSize: CGFloat = 80
		static let plopSize: CGFloat = 200
		static let maxSize: CGFloat = 800
	}
	
	struct Font {
		static let family = "Verdana"// "Consolasligaturizedv2"
		static let regular = "\(family)"
		static let bold = "\(family)-Bold"
		static let italic = "\(family)-Italic"
		static let boldItalic = "\(family)-BoldItalic"
	}
	
	struct NodeName {
		static let wall = "wall"
		static let algae = "algae"
		static let algaeFountain = "algaeFountain"
		static let water = "water"
		static let biot = "biot"
		static let grid = "grid"
		static let zapper = "zapper"
	}
		
	struct NeuralNet {
		static let newGenomeHiddenCounts = [14, 8]
		static let maxWeightValue: Float = 1
		static let maxOutputValue: Float = 2
		static let outputsSafetyCheck = false
	}
		
	struct Vision {
		static let eyeAngles = [-π/2, -π/4, 0, π/4, π/2, π]
		static let refinerAngles = [0, -π/12, π/12]
		static let colorDepth = 3 // r|g|b
		static let rayDistance: CGFloat = Biot.radius * 21
		static let displayMemory = 8
		static let inferenceMemory = 3
		static let maxObjectsPerAngle = 4
	}
	
	struct Thrust {
		static let thrusterArc = π/36
		static let leftThrustPositive = π/2 + thrusterArc
		static let leftThrustNegative = π/2 - thrusterArc
		static let rightThrustNegative = -π/2 + thrusterArc
		static let rightThrustPositive = -π/2 - thrusterArc
		static let thrusterSpots = [leftThrustPositive, leftThrustNegative, rightThrustPositive, rightThrustNegative]
		
		static let displayMemory = 8
		static let inferenceMemory = 3
		
		static let spinLimiter: CGFloat = 0.4
		static let thrustForce: CGFloat = 7.5
		static let maxSpeedBoost: CGFloat = 1.375
	}
	
	struct Graphics {
		var isAntialiased: Bool
		var blendMode: SKBlendMode
		var shadows: Bool
		var showGrid: Bool
	}
		
	struct Window {
		var size: CGFloat
	}
	
	static let noBitMask: UInt32 = 	0

	// should be exp of 2
	struct CategoryBitMasks {
		static let wall: UInt32 = 1
		static let water: UInt32 = 2
		static let biot: UInt32 = 4
		static let algae: UInt32 = 8
	}
	
	// when to "bounce" off another
	struct CollisionBitMasks {
		static let wall = CategoryBitMasks.wall
		static let water = CategoryBitMasks.wall | CategoryBitMasks.water
		static let biot = CategoryBitMasks.wall | CategoryBitMasks.biot
		static let algae = CategoryBitMasks.wall | CategoryBitMasks.water | CategoryBitMasks.algae
	}
	
	// when to be notified of contact
	struct ContactBitMasks {
		static let biot = CategoryBitMasks.biot | CategoryBitMasks.wall | CategoryBitMasks.water | CategoryBitMasks.algae
	}
	
	// used in detecting neighboring bodies
	struct DetectionBitMasks {
		static let biot = CategoryBitMasks.biot | CategoryBitMasks.water | CategoryBitMasks.algae | CategoryBitMasks.wall
	}
	struct Colors {
		static let background = SKColor(white: 0.125, alpha: 1)
		static let grid = SKColor(white: 0.08125, alpha: 1)
		static let wall = SKColor(red: 0.4125, green: 0.1288, blue: 0.1288, alpha: 1)
		static let water = SKColor(red: 0.1, green: 0.3594, blue: 0.55, alpha: 1)
		static let mud = SKColor(red: 0.4196, green: 0.3333, blue: 0.2627, alpha: 1) // 107, 85, 67
		static let algae = SKColor(red: 0.1137, green: 0.439, blue: 0.1137, alpha: 1)
	}
	
	struct VisionColors {
		static let wall = SKColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
		static let water = SKColor(srgbRed: 0, green: 0.5, blue: 1, alpha: 1)
		static let mud = SKColor(srgbRed: 0.42, green: 0.36, blue: 0.26, alpha: 1)
		static let algae = SKColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
		static let algaeFromBiot = SKColor(srgbRed: 1, green: 1, blue: 0, alpha: 1)
	}
		
	struct Camera {
		static let initialScale: CGFloat = 3
		static let zoomMin: CGFloat = 0.1
		static let zoomMax: CGFloat = 20
		static let levelOfDetailMedium: CGFloat = 2.3
		static let levelOfDetailLow: CGFloat = 5
		static let scaleFactor: CGFloat = 1.25
		static let panBoost: CGFloat = 100
		static let animationDuration: TimeInterval = 0.25
	}
	
	struct ZeeOrder {
		static let scene: CGFloat = -100
		static let background: CGFloat = -10
		static let grid: CGFloat = -3
		static let water: CGFloat = 1
		static let wall: CGFloat = 0
		static let algae: CGFloat = 1
		static let biot: CGFloat = 5
		static let stats: CGFloat = 500
	}
	
	struct Stats {
		static let labelAttrs: [AttributedStringBuilder.Attribute] = [
			.textColor(UIColor.lightGray),
			.font(UIFont.systemFont(ofSize: 14, weight: .bold))
		]
		
		static let valueAttrs: [AttributedStringBuilder.Attribute] = [
			.textColor(UIColor.white),
			.font(UIFont(name: Constants.Font.regular, size: 24)!)
		]
		
		static let iconAttrs: [AttributedStringBuilder.Attribute] = [
			.font(UIFont.systemFont(ofSize: 22, weight: .bold))
		]
	}
}

extension OctopusKit {
	public static var logForSimInfo = OKLog(title: "ℹ️")
	public static var logForSimWarnings = OKLog(title: "⚠️")
	public static var logForSimErrors = OKLog(title: "🐞")
}
