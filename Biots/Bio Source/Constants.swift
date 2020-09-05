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
		
	struct Environment {
		
		static let randomRun = false
		static let addWalls = false
		static let mutationsOff = false
		static let selfReplication = true
		static let selfReplicationMaxSpawn = 2
		static let generationTrainingThreshold = 2000
		static let fixedMarkers = true
		static let filename = "lab19.json"

		//(2*π*4000)/(2*π*3000)*15k = 20k
		static let worldRadius: CGFloat = 4000
		static let minimumCells = 20
		static let maximumCells = 32
		static let startupDelay = 20//randomRun ? 20 : 200
		static let dispenseInterval: UInt64 = randomRun ? 10 : 50
		static let showSpriteKitStats = true
	}
	
	struct Display {
//		static let size: CGFloat = 1600
//		static let statsY: CGFloat = -480
		
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
		static let background = SKColor(red: 22/255, green: 23/255, blue: 25/255, alpha: 1)
		static let grid = SKColor(white: 0.06, alpha: 1)
		static let wall =  SKColor(red: 0.3, green: 0.1875/2, blue: 0.1875/2, alpha: 0.8)
		static let algae = SKColor(red: 29/255, green: 112/255, blue: 29/255, alpha: 1)
		static let cell = SKColor(red: 0.63, green: 0.8, blue: 1, alpha: 0.5)
	}
	
	struct VisionColors {
		static let wall = SKColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
		static let algae = SKColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
	}

	struct Cell {
							
		static let radius: CGFloat = 40
		static let clockRate = 60 // ticks per 1-way cycle

		static let stateDetectionMaxProximity: CGFloat = 0.9 // 0..1
		static let stateDetectionMinProximity: CGFloat = 0.5 // 0..1

		static let collisionDamage: CGFloat = 0.125
		static let perMovementRecovery: CGFloat = 0.0015

		static let mateHealth: CGFloat = 0.75  // % of maximum health
		static let spawnHealth: CGFloat = 0.75 // % of maximum health

		static let maximumEnergy: CGFloat = Environment.randomRun ? 120 : 150
		static let initialEnergy: CGFloat = maximumEnergy * 0.75
		static let perMovementEnergy: CGFloat = 0.03
		static let speedBoostEnergy: CGFloat = 0.03
		static let speedBoostExertion: CGFloat = 0.00075
		static let blinkExertion: CGFloat = maximumEnergy * 0.02
		static let armorEnergy: CGFloat = 0.03

		static let maximumAge: CGFloat = Environment.randomRun ? 2000 : 3000
		static let matureAge: CGFloat = maximumAge * 0.2
		static let selfReplicationAge: CGFloat = maximumAge * 0.33
		static let gestationAge: CGFloat = maximumAge * 0.1
		static let interactionAge: CGFloat = maximumAge * 0.1
		static let blinkAge: CGFloat = maximumAge * 0.1 // how long until not blinking degdrades vision

		static let timeBetweenBites: TimeInterval = 3 // seconds between eating the same algae
		static let thrustForce: CGFloat = 15

		static let showSpeed = true
	}
	
	struct Algae {
		static let radius: CGFloat = 16
		static let bite: CGFloat = 40
	}
		
	struct EyeVector {
		static let eyeAngles = [-π/2, -π/4, 0, π/4, π/2, π]
		static let refinerAngles = [0, -π/12, π/12]
		static let inputZones = 4 // left|center|right|rear
		static let colorDepth = 3 // r|g|b
		static let rayDistance: CGFloat = Cell.radius * 21
	}
	
	enum StatsLine: Int { case line1, line2, line3 }

	struct Stats {
		static let maxLinesOfText = 3
		static let delimiter = "   "
	}
	
	struct Camera {
		static let initialScale: CGFloat = 3
		static let zoomMin: CGFloat = 0.1
		static let zoomMax: CGFloat = 0.005 * Constants.Environment.worldRadius
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
