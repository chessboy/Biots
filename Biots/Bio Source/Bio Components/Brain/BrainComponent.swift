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
	var senses = Senses()
	
    override var requiredComponents: [GKComponent.Type]? { return [
		SpriteKitComponent.self,
		PhysicsComponent.self,
		NeuralNetComponent.self,
	]}
			
	override func update(deltaTime seconds: TimeInterval) {
        				
		frame += 1
		
		if !frame.isMultiple(of: 2) {
			// use last inference every other frame
			action()
			return
		}
		
		guard
			let cell = coComponent(CellComponent.self),
			let neuralNetComponent = coComponent(NeuralNetComponent.self),
			let angleVisions = coComponent(VisionComponent.self)?.detect()
			else { return }
		
		var inputs = Array(repeating: Float.zero, count: Constants.EyeVector.inputZones * Constants.EyeVector.colorDepth)

		let position = cell.entityNode?.position ?? .zero
		let angle = ((cell.entityNode?.zRotation ?? .zero) + π).normalizedAngle
		let distanceToCenter = position.distance(to: .zero)/Constants.Environment.worldRadius
		let theta = atan2(position.y, position.x).normalizedAngle
		let angleToCenter = (theta + angle + π).normalizedAngle
		let proximityToCenter = Float(1 - distanceToCenter)

		senses.setSenses(
			marker1: Float(cell.genome.marker1 ? 1 : 0),
			health: Float(cell.health),
			energy: Float(cell.energy / cell.maximumEnergy),
			stamina: Float(cell.stamina),
			canMate: cell.canMate ? 1 : 0,
			pregnant: cell.isPregnant ? 1 : 0,
			onTopOfFood: cell.onTopOfFood ? 1 : 0,
			proximityToCenter: proximityToCenter,
			angleToCenter: Float(angleToCenter/(2*π)),
			clockShort: Int.timerForAge(Int(cell.age), clockRate: Constants.Cell.clockRate),
			clockLong: Int.timerForAge(Int(cell.age), clockRate: Constants.Cell.clockRate*3),
			age: Float(cell.age/Constants.Cell.oldAge)
		)
		
//		if let genome = GenomeFactory.shared.genomes.first, cell.genome.id.starts(with: genome.id) {
//			print(senses)
//		}

		let zonedVision = ZonedVision.fromAngleVisions(angleVisions)
		var angleIndex = 0
		for colorVector in [zonedVision.right, zonedVision.center, zonedVision.left, zonedVision.rear] {
			inputs[angleIndex * Constants.EyeVector.colorDepth + 0] = colorVector.red.float
			inputs[angleIndex * Constants.EyeVector.colorDepth + 1] = colorVector.green.float
			inputs[angleIndex * Constants.EyeVector.colorDepth + 2] = colorVector.blue.float
			
//			if angleIndex == 2, let id = angleVision.id {
//				print("saw \(id)")
//			}
			
			angleIndex += 1
		}
		
		inputs += senses.toArray
		
		let outputs = neuralNetComponent.infer(inputs)
		inference.infer(outputs: outputs)
		action()
	}
	
	func action() {
		
		guard let cell = coComponent(CellComponent.self), let node = entityNode as? SKShapeNode, !cell.isInteracting else { return }
	
		var newX: CGFloat = 0
		var newY: CGFloat = 0
		var newHeading: CGFloat = 0
		
		let position = node.position
		let zRotation = node.zRotation
		
		let speedBoostAverage: CGFloat = inference.speedBoost.average > 0 ? 2 : 1
		let left = inference.thrust.average.dx * Constants.Cell.thrustForce * speedBoostAverage
		let right = inference.thrust.average.dy * Constants.Cell.thrustForce * speedBoostAverage

		if abs(left - right) < 0.001 {
			// basically going straight
			newX = position.x + left * cos(zRotation)
			newY = position.y + right * sin(zRotation)
			newHeading = zRotation
		} else {
			let axisWidth = Constants.Cell.radius * 2
			let R = axisWidth * (left + right) / (2 * (right - left))
			let wd = (right - left) / axisWidth

			newX = position.x + R * sin(wd + zRotation) - R * sin(zRotation)
			newY = position.y - R * cos(wd + zRotation) + R * cos(zRotation)
			newHeading = (zRotation + wd/2).normalizedAngle // note: wd/2 limits rotation, maybe get rid of this
		}

		let newPosition = CGPoint(x: newX, y: newY)
		node.run(SKAction.move(to: newPosition, duration: 0.1))
		
		node.zRotation = newHeading
		
		// movement energy expenditure
		let forceExerted = (inference.thrust.average.dx.unsigned + inference.thrust.average.dy.unsigned)
		cell.incurEnergyChange(-Constants.Cell.perMovementEnergy * forceExerted)
		
		if speedBoostAverage > 1 {
			cell.incurEnergyChange(-Constants.Cell.perMovementEnergy)
			cell.incurStaminaChange(Constants.Cell.perMovementRecovery/2)
		}
		
		// healing
		if cell.stamina < 1 {
			let staminaRecovery = -Constants.Cell.perMovementRecovery * (1 - (forceExerted/2))
			// print("cell.stamina: \(cell.stamina.formattedTo2Places), forceExerted: \(forceExerted.formattedTo2Places), staminaRecovery: \(staminaRecovery.formattedTo4Places)")
			cell.incurStaminaChange(staminaRecovery)
			cell.incurEnergyChange(-staminaRecovery/2)
		}

		node.fillColor = inference.color.average.skColor
	}
}
