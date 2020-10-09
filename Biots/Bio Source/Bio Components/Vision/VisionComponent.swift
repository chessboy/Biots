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

struct VisionMemory {
	
	var angle: CGFloat
	var runningColorVector: RunningColorVector = RunningColorVector(memory: Constants.Vision.displayMemory)
	
	init(angle: CGFloat) {
		self.angle = angle
	}
}


final class VisionComponent: OKComponent {

	var angleVisions: [AngleVision] = []
	var visionMemory: [VisionMemory] = []

	lazy var globalDataComponent = coComponent(GlobalDataComponent.self)
	lazy var cellComponent = coComponent(CellComponent.self)
	lazy var physicsComponent = coComponent(PhysicsComponent.self)
	lazy var camera = OctopusKit.shared.currentScene?.camera
	
	override init() {
		for angle in Constants.Vision.eyeAngles {
			visionMemory.append(VisionMemory(angle: angle))
		}

		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		GlobalDataComponent.self
	]}

	// test for push
	func detect() {
		
		angleVisions.removeAll()

		guard let physicsWorld = OctopusKit.shared.currentScene?.physicsWorld,
			let showTracer = globalDataComponent?.showTracer,
			let cameraScale = camera?.xScale,
			let node = entityNode,
			let scene = OctopusKit.shared.currentScene,
			let cell = cellComponent,
			let physicsBody = physicsComponent?.physicsBody else {
			return
		}
		
		let tracerScale = (0.2 * cameraScale).clamped(0.3, 1)
		let maxObjectsPerAngle = 2
		
		for angle in Constants.Vision.eyeAngles {

			var redTotal: CGFloat = 0
			var greenTotal: CGFloat = 0
			var blueTotal: CGFloat = 0
			var pings: CGFloat = 0
			var bodiesSeenAtAngle: [SKPhysicsBody] = []

			for offset in Constants.Vision.refinerAngles {

				let angleOffset = angle + offset
				let rayDistance = cell.effectiveVisibility * Constants.Vision.rayDistance
				let rayStart = node.position + CGPoint(angle: node.zRotation + angleOffset) * Constants.Cell.radius * 0.95
				let rayEnd = rayStart + CGPoint(angle: node.zRotation + angleOffset) * rayDistance
				
				var blockerSeenAtSubAngle = false
				physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, hitPoint, normal, stop) in
					if body != physicsBody, body.categoryBitMask & Constants.DetectionBitMasks.cell > 0 {
						
						let distance = rayStart.distance(to: hitPoint)
						let proximity = 1 - distance/Constants.Vision.rayDistance
						var detectedColor: SKColor = SKColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
						
						if !blockerSeenAtSubAngle, !bodiesSeenAtAngle.contains(body), let object = scene.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == body }).first as? OKEntity {

							if body.categoryBitMask & Constants.CategoryBitMasks.wall > 0 {
								// wall
								detectedColor = Constants.VisionColors.wall
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: rayStart + CGPoint(angle: node.zRotation + angleOffset) * distance, color: Constants.Colors.wall.withAlpha(proximity), scale: tracerScale)
								}
							}
							else if body.categoryBitMask & Constants.CategoryBitMasks.water > 0 {
								// water
								detectedColor = Constants.VisionColors.water
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: rayStart + CGPoint(angle: node.zRotation + angleOffset) * distance, color: Constants.Colors.water.withAlpha(proximity), scale: tracerScale)
								}
							}
							else if !blockerSeenAtSubAngle, let otherCellComponent = object.component(ofType: CellComponent.self) {
								// cell
								detectedColor = otherCellComponent.bodyColor
								bodiesSeenAtAngle.append(body)
								blockerSeenAtSubAngle = true
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: otherCellComponent.entityNode?.position ?? .zero, color: detectedColor.withAlpha(proximity), scale: tracerScale)
								}
							}
							else if !blockerSeenAtSubAngle, let algae = object.component(ofType: AlgaeComponent.self) {
								// algae
								detectedColor = Constants.VisionColors.algae
								bodiesSeenAtAngle.append(body)
								if showTracer {
									self.showTracer(rayStart: rayStart, rayEnd: algae.entityNode?.position ?? .zero, color: Constants.Colors.algae.withAlpha(proximity), scale: tracerScale)
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
			
			var colorVector = ColorVector.zero
			
			if pings > 0 {
				colorVector = ColorVector(red: redTotal/pings, green: greenTotal/pings, blue: blueTotal/pings)
				let angleVision = AngleVision(angle: angle, colorVector: colorVector)
				angleVisions.append(angleVision)
			}
			
			if let visionMemory = visionMemory.filter({ $0.angle == angle }).first {
				visionMemory.runningColorVector.addValue(colorVector)
			}
		}
	}

	func showTracer(rayStart: CGPoint, rayEnd: CGPoint, color: SKColor, scale: CGFloat) {
		let path = CGMutablePath()
		let tracerNode = SKShapeNode()
		tracerNode.lineWidth = 0.0015 * Constants.Env.worldRadius * scale
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
