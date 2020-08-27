//
//  VisionComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/14/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class VisionComponent: OKComponent {

	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		GlobalDataComponent.self
	]}

	func detect() -> [Detection] {

		let showTracer = coComponent(GlobalDataComponent.self)?.showTracer ?? false

		var detections: [Detection] = []

		guard let physicsWorld = OctopusKit.shared.currentScene?.physicsWorld,
			let node = entityNode,
			let scene = OctopusKit.shared.currentScene,
			let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody else {
			return []
		}

		var angleIndex = 0
		let maxObjectsPerAngle = 2

		for angle in Constants.EyeVector.eyeAngles {

			var bodiesSeenAtAngle: [SKPhysicsBody] = []
			for offset in Constants.EyeVector.refinerAngles {

				let rayDistance = Constants.EyeVector.rayDistance
				let rayStart = node.position + CGPoint(angle: node.zRotation + angle + offset) * Constants.Cell.radius * 0.95
				let rayEnd = rayStart + CGPoint(angle: node.zRotation + angle + offset) * rayDistance

				var blockerSeenAtSubAngle = false
				physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, hitPoint, normal, stop) in
					if body != physicsBody, body.categoryBitMask & Constants.DetectionBitMasks.cell > 0 {
						let distance = rayStart.distance(to: hitPoint)
						let proximity = 1 - distance/rayDistance

						if !blockerSeenAtSubAngle, !bodiesSeenAtAngle.contains(body), let object = scene.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == body }).first as? OKEntity {

							if let _ = object.component(ofType: BoundaryComponent.self) {
								let detection = Detection(angleIndex: angleIndex, detectableObject: DetectableObject.wall, proximity: proximity)
								detections.append(detection)
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									let color = detection.detectableObject.skColor.withAlpha(proximity)
									self.showTracer(angle: node.zRotation + angle + offset, rayStart: rayStart, distance: distance, color: color)
								}
							}
							else if !blockerSeenAtSubAngle, let otherCellComponent = object.component(ofType: CellComponent.self) {
								let id = angleIndex == Constants.EyeVector.eyeAngleZeroDegreesIndex ? otherCellComponent.genome.id : ""
								let detection = Detection(id: id, angleIndex: angleIndex, detectableObject: DetectableObject.cell, proximity: proximity)
								detections.append(detection)

								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									let color = detection.detectableObject.skColor.withAlpha(proximity)
									self.showTracer(rayStart: rayStart, rayEnd: otherCellComponent.entityNode?.position ?? .zero, color: color)
								}
							}
							else if !blockerSeenAtSubAngle, let algae = object.component(ofType: AlgaeComponent.self) {
								let detection = Detection(angleIndex: angleIndex, detectableObject: DetectableObject.algae, proximity: proximity)
								detections.append(detection)
								bodiesSeenAtAngle.append(body)
								if showTracer {
									let color = detection.detectableObject.skColor.withAlpha(proximity)
									self.showTracer(rayStart: rayStart, rayEnd: algae.entityNode?.position ?? .zero, color: color)
								}
							}
							else {
								OctopusKit.logForSim.add("detected object unknown: \(body.categoryBitMask)")
							}
						}
						
						if bodiesSeenAtAngle.count == maxObjectsPerAngle || blockerSeenAtSubAngle {
							stop[0] = true
						}
					}
				}
			}
			angleIndex += 1
		}

		// prune detections
		var prunedDetections: [Detection] = []
		for angleIndex in 0..<Constants.EyeVector.eyeAngles.count {
			for detectableObject in DetectableObject.allCases {
				if let closestOfTypeAtAngle = detections.filter({$0.angleIndex == angleIndex && $0.detectableObject == detectableObject}).sorted(by: { (detection1, detection2) -> Bool in
					detection1.proximity > detection2.proximity
				}).first {
					prunedDetections.append(closestOfTypeAtAngle)
				}
			}
		}

		// if prunedDetections.count > 0 { print(detections) }
		return prunedDetections
	}

	func showTracer(angle: CGFloat, rayStart: CGPoint, distance: CGFloat, color: SKColor) {
		let path = CGMutablePath()
		let tracerNode = SKShapeNode()
		tracerNode.lineWidth = 0.0015 * Constants.Environment.worldRadius
		tracerNode.strokeColor = color
		tracerNode.zPosition = Constants.ZeeOrder.cell - 0.1
		path.move(to: rayStart)
		path.addLine(to: rayStart + CGPoint(angle: angle) * distance)
		tracerNode.path = path
		OctopusKit.shared.currentScene?.addChild(tracerNode)
		tracerNode.run(SKAction.wait(forDuration: 0.15)) {
			tracerNode.removeFromParent()
		}
	}

	func showTracer(rayStart: CGPoint, rayEnd: CGPoint, color: SKColor) {
		let path = CGMutablePath()
		let tracerNode = SKShapeNode()
		tracerNode.lineWidth = 0.0015 * Constants.Environment.worldRadius
		tracerNode.strokeColor = color
		tracerNode.zPosition = Constants.ZeeOrder.cell - 0.1
		path.move(to: rayStart)
		path.addLine(to: rayEnd)
		tracerNode.path = path
		OctopusKit.shared.currentScene?.addChild(tracerNode)
		tracerNode.run(SKAction.wait(forDuration: 0.15)) {
			tracerNode.removeFromParent()
		}
	}

}
