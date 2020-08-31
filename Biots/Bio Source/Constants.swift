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
		static let addWalls = true
		static let mutationsOff = false
		static let selfReplication = true
		static let generationTrainingThreshold = 2000
		static let fixedMarkers = true
		static let filename = "lab5.json"

		static let worldRadius: CGFloat = randomRun ? 3000 : 3200
		static let minimumCells = 20
		static let maximumCells = 32
		static let startupDelay = randomRun ? 20 : 200
		static let dispenseInterval: UInt64 = randomRun ? 10 : 50
		static let showSpriteKitStats = true
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
		static let wall =  SKColor(red: 0.6, green: 0.1875, blue: 0.1875, alpha: 1)
		static let algae = SKColor(red: 29/255, green: 112/255, blue: 29/255, alpha: 1)
		static let background = SKColor(red: 17/255, green: 18/255, blue: 20/255, alpha: 1)
		static let cell = SKColor(red: 0.63, green: 0.8, blue: 1, alpha: 0.5)
		
		static let maleCell = SKColor(red: 0.5, green: 0.5, blue: 0.8, alpha: 1)
		static let maleMatingCell = SKColor(red: 0.7, green: 0.7, blue: 1, alpha: 1)
		static let malePregnantCell = SKColor(red: 0.8, green: 0.8, blue: 1, alpha: 1)

		static let femaleCell = SKColor(red: 0.8, green: 0.55, blue: 0.55, alpha: 1)
		static let femaleMatingCell = SKColor(red: 1, green: 0.75, blue: 0.75, alpha: 1)
		static let femalePregnantCell = SKColor(red: 1, green: 0.85, blue: 0.85, alpha: 1)
	}
	
	struct VisionColors {
		static let wall = SKColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
		static let algae = SKColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
	}

	struct Cell {
							
		static let radius: CGFloat = 40
		static let stateDetectionProximity: CGFloat = 0.4 // 0..1
		static let clockRate = 60 // Hz

		static let collisionDamage: CGFloat = 0.125
		static let attackDamage: CGFloat = 0.3
		static let perMovementRecovery: CGFloat = 0.0015

		static let mateHealth: CGFloat = 0.75  // % of maximum health
		static let spawnHealth: CGFloat = 0.65 // % of maximum health

		static let maximumEnergy: CGFloat = Environment.randomRun ? 120 : 150
		static let initialEnergy: CGFloat = maximumEnergy * 0.5
		static let perMovementEnergy: CGFloat = 0.03
		static let speedBoostEnergy: CGFloat = 0.03
		static let speedBoostExertion: CGFloat = 0.00075
		static let blinkExertion: CGFloat = maximumEnergy * 0.02

		static let oldAge: CGFloat = Environment.randomRun ? 2000 : 2800
		static let matureAge: CGFloat = oldAge * 0.2 // % of old age
		static let selfReplicationAge: CGFloat = oldAge * 0.33
		static let gestationAge: CGFloat = oldAge * 0.1 // % of old age
		static let interactionAge: CGFloat = oldAge * 0.1 // % of old age
		static let blinkAge: CGFloat = oldAge * 0.1 // % of old age

		static let timeBetweenBites: TimeInterval = 3 // seconds between eating the same algae
		static let thrustForce: CGFloat = 15

		static let showSpeed = true
		static let matingOutputThreshold: Float = 0.55
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
		static let rayDistance: CGFloat = Environment.worldRadius * 0.28
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
		static let wall: CGFloat = 0
		static let algae: CGFloat = 1
		static let cell: CGFloat = 2
		static let stats: CGFloat = 100
	}
}

extension OctopusKit {
	public static var logForSim = OKLog(title: "🐠")
}
