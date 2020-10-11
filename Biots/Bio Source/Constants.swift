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
		
	struct NeuralNet {
		static let newGenomeHiddenCounts = [14, 8]
		static let maxWeightValue: Float = 1
	}
	
	struct Env {
		
		static let zooFilename = "zoo-06.json"
		static let placementsFilename = "medium-placements.json"

		static let randomRun = false
		static let easyMode = false
		
		static let gridBlockSize: CGFloat = 400
		static let worldRadius: CGFloat = gridBlockSize * (easyMode ? 13 : 15) // 20k food works well here

		static let selfReplication = true
		static let selfReplicationMaxSpawn = 3
		static let unbornGenomeCacheCount = 80
		
		static let minimumCells = 10
		static let maximumCells = 20
		static let startupDelay = randomRun ? 20 : 250
		static let dispenseInterval: UInt64 = randomRun ? 10 : 50
		static let showSpriteKitStats = true
		
		static let simpleGraphics = Graphics(antialiased: false, blendMode: .replace, shadows: false, showGrid: false)
		static let niceGraphics = Graphics(antialiased: true, blendMode: .alpha, shadows: true, showGrid: true)
		static let graphics = simpleGraphics
	}
	
	struct Cell {
		static let radius: CGFloat = 40
		static let clockRate = 60 // ticks per 1-way cycle

		static let collisionDamage: CGFloat = Env.easyMode ?  0.1 :  0.15
		static let perMovementRecovery: CGFloat = Env.easyMode ?  0.0015 :  0.00125

		static let mateHealth: CGFloat = Env.easyMode ? 0.7 : 0.75 // % of maximum health
		static let spawnHealth: CGFloat = Env.easyMode ? 0.6 : 0.65 // % of maximum health

		static let maximumFoodEnergy: CGFloat = Env.easyMode ? 100 : 120
		static let initialFoodEnergy: CGFloat = maximumFoodEnergy * 0.5
		static let maximumHydration: CGFloat = Env.easyMode ? 85 : 100
		static let initialHydration: CGFloat = maximumHydration * (Env.easyMode ? 0.65 : 0.55)

		static let perMovementEnergy: CGFloat = 0.01
		static let perMovementHydration: CGFloat = Env.easyMode ? 0.0075 : 0.0085
		static let armorEnergy: CGFloat = 0.06
		static let speedBoostExertion: CGFloat = 0.0004
		static let maxSpeedBoost: CGFloat = 1.375

		static let maximumAge: CGFloat = Env.easyMode ? 2400 : 3000
		static let matureAge: CGFloat = maximumAge * 0.2
		static let gestationAge: CGFloat = maximumAge * 0.15
		static let blinkAge: CGFloat = maximumAge * 0.1 // duration until not blinking degrades vision
		
		static let adjustBodyColor = false
		
		enum StatsLine: Int { case line1, line2, line3 }

		struct Stats {
			static let maxLinesOfText = 3
			static let delimiter = "   "
		}
	}
	
	struct Algae {
		static let radius: CGFloat = 16
		static let bite: CGFloat = Cell.maximumFoodEnergy * 0.2
		static let timeBetweenBites: TimeInterval = 3 // seconds between eating the same algae
	}
	
	struct Water {
		static let sip: CGFloat = Cell.maximumHydration * 0.25
		static let timeBetweenSips: TimeInterval = 3 // seconds between drinking the same water
	}
	
	struct Vision {
		static let eyeAngles = [-π/2, -π/4, 0, π/4, π/2, π]
		static let refinerAngles = [0, -π/12, π/12]
		static let colorDepth = 3 // r|g|b
		static let rayDistance: CGFloat = Cell.radius * 21
		static let displayMemory = 8
		static let inferenceMemory = 3
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
		
		static let spinLimiter: CGFloat = 1/π
		static let thrustForce: CGFloat = 7.5
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
		static let water: UInt32 = 2
		static let cell: UInt32 = 4
		static let algae: UInt32 = 8
	}
	
	// when to "bounce" off another
	struct CollisionBitMasks {
		static let wall = CategoryBitMasks.wall
		static let water = CategoryBitMasks.wall | CategoryBitMasks.water
		static let cell = CategoryBitMasks.wall | CategoryBitMasks.cell
		static let algae = CategoryBitMasks.wall | CategoryBitMasks.water | CategoryBitMasks.algae
	}
	
	// when to be notified of contact
	struct ContactBitMasks {
		static let cell = CategoryBitMasks.cell | CategoryBitMasks.wall | CategoryBitMasks.water | CategoryBitMasks.algae
	}
	
	// used in detecting neighboring bodies
	struct DetectionBitMasks {
		static let cell = CategoryBitMasks.cell | CategoryBitMasks.water | CategoryBitMasks.algae | CategoryBitMasks.wall
	}
	
	struct Colors {
		static let background = SKColor(white: 0.125, alpha: 1)
		static let grid = NSColor(white: 0.08125, alpha: 1)
		static let wall =  SKColor(red: 0.3, green: 0.1875/2, blue: 0.1875/2, alpha: 0.8)
		static let water =  SKColor(red: 0.1875/2, green: 0.3, blue: 0.3, alpha: 0.8)
		static let algae = SKColor(red: 29/255, green: 112/255, blue: 29/255, alpha: 1)
	}
	
	struct VisionColors {
		static let wall = SKColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
		static let water = SKColor(srgbRed: 0, green: 1, blue: 1, alpha: 1)
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
		static let water: CGFloat = 1
		static let algae: CGFloat = 1
		static let cell: CGFloat = 5
		static let stats: CGFloat = 100
	}
}

extension OctopusKit {
	public static var logForSim = OKLog(title: "🐠")
}
