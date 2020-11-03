//
//  BrainComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/15/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class BrainComponent: OKComponent {

	var inference = Inference()
	var frame = Int.random(100)
	var senses: Senses!
	
	lazy var biotComponent = coComponent(BiotComponent.self)
	lazy var neuralNetComponent = coComponent(NeuralNetComponent.self)
	lazy var visionComponent = coComponent(VisionComponent.self)

	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		PhysicsComponent.self,
		NeuralNetComponent.self,
	]}
	
	override func update(deltaTime seconds: TimeInterval) {
    				
		if senses == nil, let biot = biotComponent {
			senses = Senses(inputCount: biot.genome.inputCount)
		}
		
		frame += 1
		
		if !frame.isMultiple(of: 2) {
			// use last inference every other frame
			action()
			return
		}
		
		guard
			let biot = biotComponent,
			let neuralNet = neuralNetComponent,
			let vision = visionComponent
			else { return }
		
		let clockRate = GameManager.shared.gameConfig.clockRate
		
		vision.detect()
		
		senses.setSenses(
			health: Float(biot.health),
			energy: Float(biot.foodEnergy / biot.maximumEnergy),
			hydration: Float(biot.hydration / biot.maximumHydration),
			stamina: Float(biot.stamina),
			pregnant: biot.isPregnant ? 1 : 0,
			onTopOfFood: biot.isOnTopOfFood ? 1 : 0,
			onTopOfWater: biot.isOnTopOfWater ? 1 : 0,
			onTopOfMud: biot.isOnTopOfMud ? 1 : 0,
			progress: biot.progress.float,
			clockShort: Int.timerForAge(Int(biot.age), clockRate: clockRate),
			clockLong: Int.timerForAge(Int(biot.age), clockRate: clockRate*3),
			age: Float(biot.age/biot.maximumAge)
		)
		
//		if let genome = GenomeFactory.shared.genomes.first, biot.genome.id.starts(with: genome.id) {
//			print(senses)
//		}

		var inputs = Array(repeating: Float.zero, count: Constants.Vision.eyeAngles.count * Constants.Vision.colorDepth)
						
		let actionMemory = Constants.Vision.inferenceMemory
		var angleIndex = 0
		for angle in Constants.Vision.eyeAngles {
			
			if let angleVision = vision.visionMemory.filter({ $0.angle == angle }).first {
				let color = angleVision.runningColorVector.averageOfMostRecent(memory: actionMemory).skColor
				inputs[angleIndex * Constants.Vision.colorDepth] = color.redComponent.float
				inputs[angleIndex * Constants.Vision.colorDepth + 1] = color.greenComponent.float
				inputs[angleIndex * Constants.Vision.colorDepth + 2] = color.blueComponent.float
			}
			angleIndex += 1
		}

		inputs += senses.toArray
		
		let outputs = neuralNet.infer(inputs)
		inference.infer(outputs: outputs)
		action()
	}
	
	func newPositionAndHeading(node: SKNode, thrust: CGVector) -> (position: CGPoint, heading: CGFloat) {
		var newX: CGFloat = 0
		var newY: CGFloat = 0
		var newHeading: CGFloat = 0
		
		let position = node.position
		let zRotation = node.zRotation
		let left = thrust.dx
		let right = thrust.dy
		
		if abs(left - right) < 0.001 {
			// basically going straight
			newX = position.x + left * cos(zRotation)
			newY = position.y + right * sin(zRotation)
			newHeading = zRotation
		}
		else {
			let axisWidth = Constants.Biot.radius * 2
			let R = axisWidth * (left + right) / (2 * (right - left))
			let wd = (right - left) / axisWidth

			newX = position.x + R * sin(wd + zRotation) - R * sin(zRotation)
			newY = position.y - R * cos(wd + zRotation) + R * cos(zRotation)
			newHeading = (zRotation + (wd * Constants.Thrust.spinLimiter)).normalizedAngle // note: shrinking `w` limits rotation
		}

		return (position: CGPoint(x: newX, y: newY), heading: newHeading)
	}
	
	func action() {
		
		guard
			let biot = biotComponent,
			let node = entityNode as? SKSpriteNode, !biot.isInteracting else { return }
	
		let gameConfig = GameManager.shared.gameConfig
		var thrustAverage = inference.thrust.averageOfMostRecent(memory: Constants.Thrust.inferenceMemory)
		
		let dampeningMud = gameConfig.dampeningWater * 2
		let impediment = senses.onTopOfWater.average.cgFloat * gameConfig.dampeningWater + senses.onTopOfMud.average.cgFloat * dampeningMud
		let dampening = 1 - impediment
//		if senses.onTopOfWater.average + senses.onTopOfMud.average > 0 {
//			print("thrust: \(thrustAverage.formattedTo2Places), dampening: \(dampening.formattedTo2Places), new: \((thrustAverage * dampening).formattedTo2Places)")
//		}
		
		thrustAverage *= dampening
		let speedBoost: CGFloat = max(inference.speedBoost.average.cgFloat * Constants.Thrust.maxSpeedBoost, 1)
		let armor: CGFloat = inference.armor.average.cgFloat
		let left = thrustAverage.dx * Constants.Thrust.thrustForce * speedBoost
		let right = thrustAverage.dy * Constants.Thrust.thrustForce * speedBoost

		// determine new position and heading
		let (newPosition, newHeading) = newPositionAndHeading(node: node, thrust: CGVector(dx: left, dy: right))
		//node.run(SKAction.move(to: newPosition, duration: 0.05))
		node.position = newPosition
		node.zRotation = newHeading
		
		// movement energy expenditure
		let perMovementEnergyCost = gameConfig.perMovementEnergyCost.valueForGeneration(biot.genome.generation)
		let forceExerted = (thrustAverage.dx.unsigned + thrustAverage.dy.unsigned)
		biot.incurEnergyChange(-perMovementEnergyCost * forceExerted)
		
		let perMovementHydrationCost = gameConfig.perMovementHydrationCost.valueForGeneration(biot.genome.generation)
		biot.incurHydrationChange(-perMovementHydrationCost * forceExerted)

		if speedBoost > 1 {
			let speedBoostStaminaCost = gameConfig.speedBoostStaminaCost.valueForGeneration(biot.genome.generation)
			biot.incurEnergyChange(-perMovementEnergyCost)
			biot.incurHydrationChange(-perMovementHydrationCost)
			biot.incurStaminaChange(speedBoostStaminaCost)
		}
		
		if armor > 0 {
			let armorEnergyCost = gameConfig.armorEnergyCost.valueForGeneration(biot.genome.generation)
			biot.incurEnergyChange(-armorEnergyCost * armor)
		}
		
		// healing
		if biot.stamina < 1 {
			let perMovementRecovery = GameManager.shared.gameConfig.perMovementStaminaRecovery.valueForGeneration(biot.genome.generation)
			let staminaRecovery = -perMovementRecovery * (1 - (forceExerted/3))
			// print("biot.stamina: \(biot.stamina.formattedTo2Places), forceExerted: \(forceExerted.formattedTo2Places), staminaRecovery: \(staminaRecovery.formattedTo4Places)")
			biot.incurStaminaChange(staminaRecovery)
		}
        
		if Constants.Biot.adjustBodyColor {
			let minRGB: CGFloat = 0.25
			let skColor = inference.color.average.skColor
			let adjustedRed = skColor.redComponent.clamped(minRGB, 1)
			let adjustedGreen = skColor.greenComponent.clamped(minRGB, 1)
			let adjustedBlue = skColor.blueComponent.clamped(minRGB, 1)
			let alpha: CGFloat = Constants.Env.graphics.blendMode != .replace ? (biot.age > biot.maximumAge * 0.85 ? 0.33 : 0.667) : 1
			let adjustedColor = SKColor(red: adjustedRed, green: adjustedGreen, blue: adjustedBlue, alpha: alpha)
			node.color = adjustedColor
		}
		else {
			if Constants.Env.graphics.blendMode != .replace {
				node.color = inference.color.average.skColor.withAlpha(biot.age > biot.maximumAge * 0.85 ? 0.33 : 0.667)
			} else {
				node.color = inference.color.average.skColor
			}
		}
	}    
}
