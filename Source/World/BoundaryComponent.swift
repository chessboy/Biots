//
//  BoundaryComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/14/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class BoundaryComponent: OKComponent {
	
	static let strokeWidth = Constants.Biot.radius * 2

	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		PhysicsComponent.self
	]}
	
	static func createCircularBarrier(radius: CGFloat) -> OKEntity {
		
		let node = SKShapeNode(circleOfRadius: radius)
		node.name = Constants.NodeName.wall
		node.lineWidth = 0
		node.fillColor = .black
		node.isAntialiased = Constants.Env.graphics.isAntialiased

		let physicsBody = SKPhysicsBody(circleOfRadius: radius)
		physicsBody.allowsRotation = false
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.wall
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.wall

		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			BoundaryComponent()
		])
	}

	static func createLoopWall(radius: CGFloat) -> OKEntity {
		
		let node = SKShapeNode(circleOfRadius: radius + strokeWidth/2)
		node.name = Constants.NodeName.wall
		node.lineWidth = strokeWidth + 10
		node.fillColor = Constants.Colors.background
		node.strokeColor = Constants.Colors.grid
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.isAntialiased
		node.zPosition = Constants.ZeeOrder.background
	
		let topNode = SKShapeNode(circleOfRadius: radius + strokeWidth/2)
		topNode.lineWidth = strokeWidth
		topNode.strokeColor = Constants.Env.graphics.shadows ? (Constants.Colors.wall.blended(withFraction: 0.05, of: .white)?.withAlpha(0.8) ?? .red) : Constants.Colors.wall
		topNode.blendMode = Constants.Env.graphics.blendMode
		topNode.isAntialiased = Constants.Env.graphics.isAntialiased
		topNode.zPosition = Constants.ZeeOrder.wall
		node.addChild(topNode)
		
		if Constants.Env.graphics.shadows {
			let shadowWidth = strokeWidth/4
			let shadowRadius = radius + shadowWidth/4
			let shadowNode =  SKShapeNode(circleOfRadius: shadowRadius)
			shadowNode.zPosition = Constants.ZeeOrder.wall - 0.1
			shadowNode.glowWidth = shadowWidth
			shadowNode.lineWidth = shadowWidth
			shadowNode.strokeColor = SKColor.black.withAlpha(0.167)
			node.insertChild(shadowNode, at: 0)
		}

		let physicsBody = SKPhysicsBody(edgeLoopFrom: SKShapeNode(circleOfRadius: radius).path!)
		
		physicsBody.allowsRotation = false
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.wall
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.wall
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			BoundaryComponent()
		])
	}
	
	static func createLine(rect: CGRect) -> OKEntity {
		let minDim = min(rect.size.width, rect.size.height)
		let node = SKShapeNode(rect: rect, cornerRadius: minDim/2)
		node.name = Constants.NodeName.wall
		node.zPosition = Constants.ZeeOrder.wall
		node.lineWidth = 0
		node.fillColor = Constants.Colors.wall
		node.strokeColor = .clear
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.isAntialiased
		
		let physicsBody = SKPhysicsBody(polygonFrom: node.path!)
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.wall
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.wall
		
		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			BoundaryComponent()
		])
	}
	
	static func createVerticalWall(y1: CGFloat, y2: CGFloat, x: CGFloat) -> OKEntity {
		let height = y1-y2
		let rect = CGRect(x: x-strokeWidth/2, y: y1-height, width: strokeWidth, height: height)
		return createLine(rect: rect)
	}
	
	static func createHorizontalWall(x1: CGFloat, x2: CGFloat, y: CGFloat) -> OKEntity {
		let width = x1-x2
		let rect = CGRect(x: x1-width, y: y-strokeWidth/2, width: width, height: strokeWidth)
		return createLine(rect: rect)
	}
	
	static func createStraightWall(center: CGPoint, angle: CGFloat, length: CGFloat) -> OKEntity {
		let rect = CGRect(center: center, size: CGSize(width: length, height: strokeWidth))
		let entity = createLine(rect: rect)
		entity.node?.zRotation = angle
		return entity
	}
}

