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
			let detections = coComponent(VisionComponent.self)?.detect(),
			let neuralNetComponent = coComponent(NeuralNetComponent.self) else { return }

		let position = cell.entityNode?.position ?? .zero
		let angle = ((cell.entityNode?.zRotation ?? .zero) + π).normalizedAngle
		let distanceToCenter = position.distance(to: .zero)/Constants.Environment.worldRadius
		let theta = atan2(position.y, position.x).normalizedAngle
		let angleToCenter = (theta + angle + π).normalizedAngle
		let proximityToCenter = Float(1 - distanceToCenter)

		senses.setSenses(
			gender: cell.genome.gender.inputValue,
			pregnant: cell.isPregnant ? 1 : 0,
			canMate: cell.canMate ? 1 : 0,
			health: Float(cell.health),
			energy: Float(cell.energy / cell.maximumEnergy),
			damage: Float(1-cell.damage),
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

		//let inputs = Detection.detectionsToInputs(detections, senses: senses, training: cell.genome.generation <= Constants.Environment.generationTrainingThreshold)
		let inputs = Detection.detectionsToInputs(detections, senses: senses)

//		if cell.genome.id == "2528C8FB-722D-4C9D-9733-FF2B9F4FEBAF-0" {
//			print(inputs.map({$0.formattedTo2Places}))
//		}

		let outputs = neuralNetComponent.infer(inputs)
		let inference = Inference(detections: detections, outputs: outputs)
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
		
		//node.fillColor = runningInference.averageColor
	}
}
