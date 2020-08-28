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

struct AngleVision {
	
	var angle: CGFloat = 0
	var colorVector: ColorVector = .zero
	
	init(angle: CGFloat, colorVector: ColorVector) {
		self.angle = angle
		self.colorVector = colorVector
	}
}

final class VisionComponent: OKComponent {

	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		GlobalDataComponent.self
	]}

	func detect() -> [AngleVision] {
		
		// 0 (nothing visible) ... 1 (object touching)
		var angleVisions: [AngleVision] = []

		let showTracer = coComponent(GlobalDataComponent.self)?.showTracer ?? false

		guard let physicsWorld = OctopusKit.shared.currentScene?.physicsWorld,
			let node = entityNode,
			let scene = OctopusKit.shared.currentScene,
			let physicsBody = coComponent(PhysicsComponent.self)?.physicsBody else {
			return []
		}

		let maxObjectsPerAngle = 2
		
		for angle in Constants.EyeVector.eyeAngles {

			var redTotal: CGFloat = 0
			var greenTotal: CGFloat = 0
			var blueTotal: CGFloat = 0
			var pings: CGFloat = 0
			var bodiesSeenAtAngle: [SKPhysicsBody] = []
			
			for offset in Constants.EyeVector.refinerAngles {

				let angleOffset = angle + offset
				let rayDistance = Constants.EyeVector.rayDistance
				let rayStart = node.position + CGPoint(angle: node.zRotation + angleOffset) * Constants.Cell.radius * 0.95
				let rayEnd = rayStart + CGPoint(angle: node.zRotation + angleOffset) * rayDistance

				var blockerSeenAtSubAngle = false
				physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, hitPoint, normal, stop) in
					if body != physicsBody, body.categoryBitMask & Constants.DetectionBitMasks.cell > 0 {
						
						let distance = rayStart.distance(to: hitPoint)
						let proximity = 1 - distance/rayDistance
						var color: SKColor = SKColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
						
						if !blockerSeenAtSubAngle, !bodiesSeenAtAngle.contains(body), let object = scene.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == body }).first as? OKEntity {

							// wall
							if let _ = object.component(ofType: BoundaryComponent.self) {
								color = Constants.VisionColors.wall
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									self.showTracer(angle: node.zRotation + angleOffset, rayStart: rayStart, distance: distance, color: Constants.Colors.wall.withAlpha(proximity))
								}
							}
							else if !blockerSeenAtSubAngle, let otherCellComponent = object.component(ofType: CellComponent.self) {
								// cell
								color = otherCellComponent.skColor.withAlpha(proximity)
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: otherCellComponent.entityNode?.position ?? .zero, color: color.withAlpha(proximity))
								}
							}
							else if !blockerSeenAtSubAngle, let algae = object.component(ofType: AlgaeComponent.self) {
								// algae
								color = Constants.VisionColors.algae
								bodiesSeenAtAngle.append(body)
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: algae.entityNode?.position ?? .zero, color: Constants.Colors.algae.withAlpha(proximity))
								}
							}
							else {
								OctopusKit.logForSim.add("detected object unknown: \(body.categoryBitMask)")
							}
						}
						
						redTotal += color.redComponent * proximity
						greenTotal += color.greenComponent * proximity
						blueTotal += color.blueComponent * proximity
						pings += 1

						if bodiesSeenAtAngle.count == maxObjectsPerAngle || blockerSeenAtSubAngle {
							stop[0] = true
						}
					}
				}
			}
			
			if pings > 0 {
				let colorVector = ColorVector(red: redTotal/pings, green: greenTotal/pings, blue: blueTotal/pings)
				let angleVision = AngleVision(angle: angle, colorVector: colorVector)
				angleVisions.append(angleVision)
			}
		}
		
		return angleVisions
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
