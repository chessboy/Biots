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
    
	var runningInference = RunningInference(memory: 10)
	var frame = Int.random(100)
	var senses = Senses()
	
    override var requiredComponents: [GKComponent.Type]? { return [
		SpriteKitComponent.self,
		PhysicsComponent.self,
		NeuralNetComponent.self,
	]}
			
	override func update(deltaTime seconds: TimeInterval) {
        				
		frame += 1
		
		if !frame.isMultiple(of: 2), let lastInference = runningInference.last {
			action(inference: lastInference)
			return
		}
		
		guard
			let cell = coComponent(CellComponent.self),
			let neuralNetComponent = coComponent(NeuralNetComponent.self),
			let angleVisions = coComponent(VisionComponent.self)?.detect()
			else { return }
		
		let position = cell.entityNode?.position ?? .zero
		let angle = ((cell.entityNode?.zRotation ?? .zero) + π).normalizedAngle
		let distanceToCenter = position.distance(to: .zero)/Constants.Environment.worldRadius
		let theta = atan2(position.y, position.x).normalizedAngle
		let angleToCenter = (theta + angle + π).normalizedAngle
		let proximityToCenter = Float(1 - distanceToCenter)

		senses.setSenses(
			health: Float(cell.health),
			energy: Float(cell.energy / cell.maximumEnergy),
			damage: Float(1-cell.damage),
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

		var inputs = Array(repeating: Float.zero, count: Constants.EyeVector.eyeAngles.count * Constants.EyeVector.colorDepth)
		
//		case cell = 0
//		case algae
//		case wall

		
		var angleIndex = 0
		for angle in Constants.EyeVector.eyeAngles {
			if let angleVision = angleVisions.filter({ $0.angle == angle }).first {
				inputs[angleIndex * Constants.EyeVector.colorDepth] = angleVision.colorVector.red.float
				inputs[angleIndex * Constants.EyeVector.colorDepth + 1] = angleVision.colorVector.green.float
				inputs[angleIndex * Constants.EyeVector.colorDepth + 2] = angleVision.colorVector.blue.float
			}
			angleIndex += 1
		}
		
		inputs += senses.toArray
		
		let outputs = neuralNetComponent.infer(inputs)
		let inference = Inference(outputs: outputs)
		runningInference.addValue(inference)
		action(inference: inference)
	}
	
	func action(inference: Inference) {
		
		guard let cell = coComponent(CellComponent.self), let node = entityNode as? SKShapeNode, !cell.isInteracting else { return }
	
		var newX: CGFloat = 0
		var newY: CGFloat = 0
		var newHeading: CGFloat = 0
		
		let position = node.position
		let zRotation = node.zRotation
		
		let left = inference.thrust.dx * Constants.Cell.thrustForce
		let right = inference.thrust.dy * Constants.Cell.thrustForce

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
		let forceExerted = inference.thrust.dx.unsigned + inference.thrust.dy.unsigned
		cell.incurEnergyChange(-Constants.Cell.perMovementEnergy * forceExerted)
		
		// healing
		if cell.damage > 0 {
			let damageRecovery = -Constants.Cell.perMovementRecovery * (1 - (forceExerted/2))
			// print("cell.damage: \(cell.damage.formattedTo2Places), forceExerted: \(forceExerted.formattedTo2Places), damageRecovery: \(damageRecovery.formattedTo4Places)")
			cell.incurDamageChange(damageRecovery)
		}

		node.fillColor = runningInference.averageColor
	}
}
