//
//  BrainComponent.swift
//  BioGenesis
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
	
	lazy var cellComponent = coComponent(CellComponent.self)
	lazy var neuralNetComponent = coComponent(NeuralNetComponent.self)
	lazy var visionComponent = coComponent(VisionComponent.self)

	override var requiredComponents: [GKComponent.Type]? { return [
		SpriteKitComponent.self,
		PhysicsComponent.self,
		NeuralNetComponent.self,
	]}
	
	override func update(deltaTime seconds: TimeInterval) {
    				
		if senses == nil, let cell = cellComponent {
			senses = Senses(inputCount: cell.genome.inputCount)
		}
		
		frame += 1
		
		if !frame.isMultiple(of: 2) {
			// use last inference every other frame
			action()
			return
		}
		
		guard
			let cell = cellComponent,
			let neuralNet = neuralNetComponent,
			let vision = visionComponent
			else { return }
		
		vision.detect()
		
		let position = cell.entityNode?.position ?? .zero
		let distanceToCenter = position.distance(to: .zero)/Constants.Env.worldRadius
		let proximityToCenter = Float(1 - distanceToCenter)

		senses.setSenses(
			health: Float(cell.health),
			energy: Float(cell.energy / cell.maximumEnergy),
			stamina: Float(cell.stamina),
			pregnant: cell.isPregnant ? 1 : 0,
			onTopOfFood: cell.onTopOfFood ? 1 : 0,
			visibility: cell.visibility.float,
			proximityToCenter: proximityToCenter,
			clockShort: Int.timerForAge(Int(cell.age), clockRate: Constants.Cell.clockRate),
			clockLong: Int.timerForAge(Int(cell.age), clockRate: Constants.Cell.clockRate*3),
			age: Float(cell.age/Constants.Cell.maximumAge)
		)
		
//		if let genome = GenomeFactory.shared.genomes.first, cell.genome.id.starts(with: genome.id) {
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
			let axisWidth = Constants.Cell.radius * 2
			let R = axisWidth * (left + right) / (2 * (right - left))
			let wd = (right - left) / axisWidth

			newX = position.x + R * sin(wd + zRotation) - R * sin(zRotation)
			newY = position.y - R * cos(wd + zRotation) + R * cos(zRotation)
			newHeading = (zRotation + (wd * Constants.Cell.spinLimiter)).normalizedAngle // note: shrinking `w` limits rotation
		}

		return (position: CGPoint(x: newX, y: newY), heading: newHeading)
	}
	
	func action() {
		
		guard
			let cell = cellComponent,
			let node = entityNode as? SKShapeNode, !cell.isInteracting else { return }
	
		let thrustAverage = inference.thrust.averageOfMostRecent(memory: Constants.Thrust.inferenceMemory)
		let speedBoost: CGFloat = max(inference.speedBoost.average.cgFloat * Constants.Cell.maxSpeedBoost, 1)
		let armor: CGFloat = inference.armor.average.cgFloat
		let left = thrustAverage.dx * Constants.Cell.thrustForce * speedBoost
		let right = thrustAverage.dy * Constants.Cell.thrustForce * speedBoost

		// determine new position and heading
		let (newPosition, newHeading) = newPositionAndHeading(node: node, thrust: CGVector(dx: left, dy: right))
		node.run(SKAction.move(to: newPosition, duration: 0.05))
		node.zRotation = newHeading
		
		// movement energy expenditure
		let forceExerted = (thrustAverage.dx.unsigned + thrustAverage.dy.unsigned)
		cell.incurEnergyChange(-Constants.Cell.perMovementEnergy * forceExerted)
		
		if speedBoost > 1 {
			cell.incurEnergyChange(-Constants.Cell.perMovementEnergy)
			cell.incurStaminaChange(Constants.Cell.speedBoostExertion)
		}
		
		if armor > 0 {
			cell.incurEnergyChange(-Constants.Cell.armorEnergy * armor)
		}
		
		// healing
		if cell.stamina < 1 {
			let staminaRecovery = -Constants.Cell.perMovementRecovery * (1 - (forceExerted/2))
			// print("cell.stamina: \(cell.stamina.formattedTo2Places), forceExerted: \(forceExerted.formattedTo2Places), staminaRecovery: \(staminaRecovery.formattedTo4Places)")
			cell.incurStaminaChange(staminaRecovery)
		}
		
		// blink
		if inference.blink {
			cell.blink()
		}
		else {
			cell.checkEyeState()
		}

		if Constants.Cell.adjustBodyColor {
			let minRGB: CGFloat = 0.25
			let skColor = inference.color.average.skColor
			let adjustedRed = skColor.redComponent.clamped(minRGB, 1)
			let adjustedGreen = skColor.greenComponent.clamped(minRGB, 1)
			let adjustedBlue = skColor.blueComponent.clamped(minRGB, 1)
			let alpha: CGFloat = Constants.Env.graphics.blendMode != .replace ? (cell.age > Constants.Cell.maximumAge * 0.85 ? 0.33 : 0.667) : 1
			let adjustedColor = SKColor(red: adjustedRed, green: adjustedGreen, blue: adjustedBlue, alpha: alpha)
			node.fillColor = adjustedColor
		}
		else {
			if Constants.Env.graphics.blendMode != .replace {
				node.fillColor = inference.color.average.skColor.withAlpha(cell.age > Constants.Cell.maximumAge * 0.85 ? 0.33 : 0.667)
			} else {
				node.fillColor = inference.color.average.skColor
			}
		}
	}
}
