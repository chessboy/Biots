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
		
		static let zooFilename = "zoo-evolved.json"
		static let mixinZooFilename: String? = nil

		static let debugMode = false
		static let randomRun = false
		static let easyMode = false
		static let placedObjectsFilename = easyMode ? "placed-objects-less.json" : "placed-objects-more.json"

		static let gridBlockSize: CGFloat = 400
		static let worldRadius: CGFloat = gridBlockSize * (easyMode ? 10 : 13) // food: use 8-10k for smaller, 10-12k for larger

		static let selfReplication = true
		static let selfReplicationMaxSpawn = 3
		static let unbornGenomeCacheCount = 80
		
		static let minimumBiots = debugMode ? 1 : 12
		static let maximumBiots = debugMode ? 1 : 24
		static let startupDelay = debugMode ? 0 : randomRun ? 20 : 250
		static let dispenseInterval: UInt64 = randomRun ? 10 : 50
		static let showSpriteKitStats = true
		
		static let simpleGraphics = Graphics(isAntialiased: false, blendMode: .replace, shadows: false, showGrid: false)
		static let niceGraphics = Graphics(isAntialiased: true, blendMode: .alpha, shadows: true, showGrid: true)
		static let graphics = niceGraphics
		
		static let smallWindow = Window(size: 1600, statsY: -480)
		static let mediumWindow = Window(size: 2000, statsY: -560)
		static let largeWindow = Window(size: 2400, statsY: -700)
		static let window = mediumWindow
	}
	
	struct Biot {
		static let radius: CGFloat = 40
		static let clockRate = 60 // ticks per 1-way cycle

		static let collisionDamage: CGFloat = Env.easyMode ?  0.15 :  0.25
		static let perMovementRecovery: CGFloat = Env.easyMode ?  0.0015 :  0.00125

		static let mateHealth: CGFloat = Env.easyMode ? 0.7 : 0.8 // % of maximum health
		static let spawnHealth: CGFloat = Env.easyMode ? 0.6 : 0.75 // % of maximum health

		static let maximumFoodEnergy: CGFloat = Env.easyMode ? 100 : 120
		static let initialFoodEnergy: CGFloat = maximumFoodEnergy * 0.5
		static let maximumHydration: CGFloat = Env.easyMode ? 85 : 100
		static let initialHydration: CGFloat = maximumHydration * 0.5

		static let perMovementEnergyCost: CGFloat = 0.01
		static let perMovementHydrationCost: CGFloat = Env.easyMode ? 0.0075 : 0.01
		static let armorEnergyCost: CGFloat = 0.06
		static let speedBoostStaminaCost: CGFloat = 0.0006

		static let maximumAge: CGFloat = Env.easyMode ? 2400 : 3200
		static let matureAge: CGFloat = maximumAge * 0.2
		static let gestationAge: CGFloat = maximumAge * 0.15
		
		static let adjustBodyColor = false
		
		enum StatsLine: Int { case line1, line2, line3 }

		struct Stats {
			static let maxLinesOfText = 3
			static let delimiter = "   "
		}
	}
	
	struct NodeName {
		static let wall = "wall"
		static let algae = "algae"
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
	
	struct Algae {
		static let radius: CGFloat = 16
		static let bite: CGFloat = Biot.maximumFoodEnergy * 0.2
		static let timeBetweenBites: TimeInterval = 3 // seconds between eating the same algae
	}
	
	struct Water {
		static let sip: CGFloat = Biot.maximumHydration * 0.2
		static let timeBetweenSips: TimeInterval = 1.5 // seconds between drinking from the same water source
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
		var statsY: CGFloat
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
		static let wall = SKColor(red: 0.33 * 1.25, green: 0.103 * 1.25, blue: 0.103 * 1.25, alpha: 1)
		static let water = SKColor(red: 0.1, green: 0.2875 * 1.25, blue: 0.44 * 1.25, alpha: 1)
		static let algae = SKColor(red: 0.1137, green: 0.439, blue: 0.1137, alpha: 1)
	}
	
	struct VisionColors {
		static let wall = SKColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
		static let water = SKColor(srgbRed: 0, green: 0.5, blue: 1, alpha: 1)
		static let algae = SKColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
		static let algaeFromBiot = SKColor(srgbRed: 1, green: 1, blue: 0, alpha: 1)
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
		static let background: CGFloat = -10
		static let grid: CGFloat = -3
		static let water: CGFloat = 1
		static let wall: CGFloat = 0
		static let algae: CGFloat = 1
		static let biot: CGFloat = 5
		static let stats: CGFloat = 100
	}
}

extension OctopusKit {
	public static var logForSim = OKLog(title: "🐠")
}
