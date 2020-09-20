//
//  Constants.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

struct Constants {
		

	struct Env {
		
		static let filename = "zoo11.json"
		static let markersInEffect = 1

		static let randomRun = false
		static let gridBlockSize: CGFloat = 400
		static let worldRadius: CGFloat = gridBlockSize * (randomRun ? 10 : 12)
		static let zapperCount = Int(worldRadius * (randomRun ? 0.002 : 0.003))

		static let selfReplication = true
		static let selfReplicationMaxSpawn = 3

		static let minimumCells = 12
		static let maximumCells = 24
		static let startupDelay = randomRun ? 20 : 250
		static let dispenseInterval: UInt64 = randomRun ? 10 : 50
		static let showSpriteKitStats = true
		
		static let simpleGraphics = Graphics(antialiased: false, blendMode: .replace, shadows: false, showGrid: false)
		static let niceGraphics = Graphics(antialiased: true, blendMode: .alpha, shadows: true, showGrid: true)
		static let graphics = simpleGraphics
	}
	
	struct Algae {
		static let radius: CGFloat = 16
		static let bite: CGFloat = Cell.maximumEnergy * 0.2
	}
	
	struct Cell {
		static let radius: CGFloat = 40
		static let clockRate = 60 // ticks per 1-way cycle

		static let collisionDamage: CGFloat = 0.125 * 2
		static let perMovementRecovery: CGFloat = 0.001

		static let mateHealth: CGFloat = Env.randomRun ? 0.7 : 0.85 // % of maximum health
		static let spawnHealth: CGFloat = Env.randomRun ? 0.6 : 0.8 // % of maximum health

		static let maximumEnergy: CGFloat = Env.randomRun ? 100 : 150
		static let initialEnergy: CGFloat = maximumEnergy * 0.5
		static let blinkEnergy: CGFloat = maximumEnergy * 0.005
		static let perMovementEnergy: CGFloat = 0.011
		static let armorEnergy: CGFloat = 0.06
		static let speedBoostExertion: CGFloat = 0.0005
		static let maxSpeedBoost: CGFloat = 1.5

		static let maximumAge: CGFloat = Env.randomRun ? 2000 : 2400
		static let matureAge: CGFloat = maximumAge * 0.25
		static let selfReplicationAge: CGFloat = maximumAge * 0.25
		static let gestationAge: CGFloat = maximumAge * 0.15
		static let blinkAge: CGFloat = maximumAge * 0.1 // how long until not blinking degdrades vision

		static let timeBetweenBites: TimeInterval = 3 // seconds between eating the same algae
		static let thrustForce: CGFloat = 15
		
		static let adjustBodyColor = false
		
		enum StatsLine: Int { case line1, line2, line3 }

		struct Stats {
			static let maxLinesOfText = 3
			static let delimiter = "   "
		}
	}
	
	struct Vision {
		static let eyeAngles = [-π/2, -π/4, 0, π/4, π/2, π]
		static let refinerAngles = [0, -π/12, π/12]
		static let colorDepth = 3 // r|g|b
		static let rayDistance: CGFloat = Cell.radius * 21
		static let memory = 8
		static let actionMemory = 3
	}
	
	struct Thrust {
		static let thrusterWidth = π/36
		static let leftThrustPositive = π/2 + thrusterWidth
		static let leftThrustNegative = π/2 - thrusterWidth
		static let rightThrustNegative = -π/2 + thrusterWidth
		static let rightThrustPositive = -π/2 - thrusterWidth
		static let thrusterSpots = [leftThrustPositive, leftThrustNegative, rightThrustPositive, rightThrustNegative]
		static let actionMemory = 3
	}
	
	struct Graphics {
		var antialiased: Bool
		var blendMode: SKBlendMode
		var shadows: Bool
		var showGrid: Bool
	}
		
	struct Window {
		//static let size: CGFloat = 1600
		//static let statsY: CGFloat = -480
		static let size: CGFloat = 2000
		static let statsY: CGFloat = -560
	}
	
	static let noBitMask: UInt32 = 	0

	// should be exp of 2
	struct CategoryBitMasks {
		static let wall: UInt32 = 1
		static let cell: UInt32 = 2
		static let algae: UInt32 = 4
	}
	
	// when to "bounce" off another
	struct CollisionBitMasks {
		static let wall = CategoryBitMasks.wall
		static let cell = CategoryBitMasks.wall | CategoryBitMasks.cell
		static let algae = CategoryBitMasks.wall | CategoryBitMasks.algae
	}
	
	// when to be notified of contact
	struct ContactBitMasks {
		static let cell = CategoryBitMasks.cell | CategoryBitMasks.wall | CategoryBitMasks.algae
	}
	
	// used in detecting neighboring bodies
	struct DetectionBitMasks {
		static let cell = CategoryBitMasks.cell | CategoryBitMasks.algae | CategoryBitMasks.wall
	}
	
	struct Colors {
		static let background = SKColor(white: 0.125, alpha: 1)//SKColor(red: 22/255, green: 23/255, blue: 25/255, alpha: 1)
		static let grid = NSColor(white: 0.08125, alpha: 1)
		static let wall =  SKColor(red: 0.3, green: 0.1875/2, blue: 0.1875/2, alpha: 0.8)
		static let algae = SKColor(red: 29/255, green: 112/255, blue: 29/255, alpha: 1)
		static let cell = SKColor(red: 0.63, green: 0.8, blue: 1, alpha: 0.5)
		static let brownEyes = SKColor(red: 92/255, green: 64/255, blue: 61/255, alpha: 1)
	}
	
	struct VisionColors {
		static let wall = SKColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
		static let algae = SKColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
	}
		
	struct Camera {
		static let initialScale: CGFloat = 3
		static let zoomMin: CGFloat = 0.1
		static let zoomMax: CGFloat = 0.005 * Constants.Env.worldRadius
		static let scaleFactor: CGFloat = 1.25
		static let panBoost: CGFloat = 100
		static let animationDuration: TimeInterval = 0.25
	}
	
	struct ZeeOrder {
		static let grid: CGFloat = -3
		static let wall: CGFloat = 0
		static let algae: CGFloat = 1
		static let cell: CGFloat = 5
		static let stats: CGFloat = 100
	}
}

extension OctopusKit {
	public static var logForSim = OKLog(title: "🐠")
}
