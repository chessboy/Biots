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

struct ZonedVision {
	
	var right: ColorVector = .zero
	var center: ColorVector = .zero
	var left: ColorVector = .zero
	var rear: ColorVector = .zero
	var idAtCenter: String?

	static func fromAngleVisions(_ angleVisions: [AngleVision]) -> ZonedVision {
		// [  right center left rear  ]
		// [-π/2, -π/4, 0, π/4, π/2, π]

		var right = ColorVector.zero
		if let rightAngleVision = angleVisions.filter({ $0.angle == -π/2 }).first, let rightCenterAngleVision = angleVisions.filter({ $0.angle == -π/4 }).first {
			right = (rightAngleVision.colorVector + rightCenterAngleVision.colorVector) / 2
		}
		
		var left = ColorVector.zero
		if let leftAngleVision = angleVisions.filter({ $0.angle == π/2 }).first, let leftCenterAngleVision = angleVisions.filter({ $0.angle == π/4 }).first {
			left = (leftAngleVision.colorVector + leftCenterAngleVision.colorVector) / 2
		}
		
		let center = angleVisions.filter({ $0.angle == 0 }).first?.colorVector ?? .zero
		let rear = angleVisions.filter({ $0.angle == π }).first?.colorVector ?? .zero

		let idAtCenter = angleVisions.filter({ $0.angle == 0 && $0.id != nil }).first?.id
		
//		if let id = idAtCenter {
//			print("saw \(id)")
//		}
		
		return ZonedVision(right: right, center: center, left: left, rear: rear, idAtCenter: idAtCenter)
	}
}

struct AngleVision {
	
	var angle: CGFloat = 0
	var colorVector: ColorVector = .zero
	var id: String?
	
	init(angle: CGFloat, colorVector: ColorVector, id: String? = nil) {
		self.angle = angle
		self.colorVector = colorVector
		self.id = id
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
			let cell = coComponent(CellComponent.self),
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
			var idSeenAtAngle: String?
			
			for offset in Constants.EyeVector.refinerAngles {

				let angleOffset = angle + offset
				let rayDistance = cell.effectiveVisibility * Constants.EyeVector.rayDistance
				let rayStart = node.position + CGPoint(angle: node.zRotation + angleOffset) * Constants.Cell.radius * 0.95
				let rayEnd = rayStart + CGPoint(angle: node.zRotation + angleOffset) * rayDistance
				
				var blockerSeenAtSubAngle = false
				physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, hitPoint, normal, stop) in
					if body != physicsBody, body.categoryBitMask & Constants.DetectionBitMasks.cell > 0 {
						
						let distance = rayStart.distance(to: hitPoint)
						let proximity = 1 - distance/Constants.EyeVector.rayDistance
						var detectedColor: SKColor = SKColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
						
						if !blockerSeenAtSubAngle, !bodiesSeenAtAngle.contains(body), let object = scene.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == body }).first as? OKEntity {

							// wall
							if body.categoryBitMask & Constants.CategoryBitMasks.wall > 0 {
								detectedColor = Constants.VisionColors.wall
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									self.showTracer(angle: node.zRotation + angleOffset, rayStart: rayStart, distance: distance, color: Constants.Colors.wall.withAlpha(proximity))
								}
							}
							else if !blockerSeenAtSubAngle, let otherCellComponent = object.component(ofType: CellComponent.self) {
								// cell
								detectedColor = otherCellComponent.skColor
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if angle == 0, proximity >= Constants.Cell.stateDetectionMinProximity, proximity <= Constants.Cell.stateDetectionMaxProximity {
									idSeenAtAngle = otherCellComponent.genome.id
								}
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: otherCellComponent.entityNode?.position ?? .zero, color: detectedColor.withAlpha(proximity))
								}
							}
							else if !blockerSeenAtSubAngle, let algae = object.component(ofType: AlgaeComponent.self) {
								// algae
								detectedColor = Constants.VisionColors.algae
								bodiesSeenAtAngle.append(body)
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: algae.entityNode?.position ?? .zero, color: Constants.Colors.algae.withAlpha(proximity))
								}
							}
							else {
								OctopusKit.logForSim.add("detected object unknown: \(body.categoryBitMask)")
							}
						}
						
						redTotal += detectedColor.redComponent * proximity
						greenTotal += detectedColor.greenComponent * proximity
						blueTotal += detectedColor.blueComponent * proximity
						pings += 1

						if bodiesSeenAtAngle.count == maxObjectsPerAngle || blockerSeenAtSubAngle {
							stop[0] = true
						}
					}
				}
			}
			
			if pings > 0 {
				let colorVector = ColorVector(red: redTotal/pings, green: greenTotal/pings, blue: blueTotal/pings)
				let angleVision = AngleVision(angle: angle, colorVector: colorVector, id: idSeenAtAngle)
				angleVisions.append(angleVision)
			}
		}
		
		return angleVisions
	}

	func showTracer(angle: CGFloat, rayStart: CGPoint, distance: CGFloat, color: SKColor) {
		let path = CGMutablePath()
		let tracerNode = SKShapeNode()
		tracerNode.lineWidth = 0.0015 * Constants.Env.worldRadius
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
		tracerNode.lineWidth = 0.0015 * Constants.Env.worldRadius
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
