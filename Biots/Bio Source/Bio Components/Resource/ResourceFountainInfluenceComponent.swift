//
//  ResourceFountainInfluenceComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/21/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class ResourceFountainInfluenceComponent: OKComponent {
	
	let rootNode = SKNode()
	var labelNode: SKLabelNode!

	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		ResourceFountainInfluenceComponent.self
	]}
	
	override func didAddToEntity() {
		
		if let resourceFountainComponent = entity?.component(ofType: ResourceFountainComponent.self) {
			
			let maxRadius = resourceFountainComponent.maxRadius
			let minRadius = max(resourceFountainComponent.minRadius, 50)
			//print("maxRadius: \(maxRadius), minRadius: \(minRadius), (maxRadius - minRadius)/2: \((maxRadius - minRadius)/2)")
			
			let influenceNode = SKShapeNode.arcOfRadius(radius: minRadius + (maxRadius - minRadius)/2, startAngle: 0, endAngle: 2*π)
			influenceNode.lineWidth = maxRadius - minRadius
			influenceNode.strokeColor = SKColor.cyan.withAlpha(0.25)
			influenceNode.fillColor = .clear
			influenceNode.zPosition = 20
			rootNode.addChild(influenceNode)
			
			let labelNode = SKLabelNode(fontNamed: "Consolas")
			labelNode.horizontalAlignmentMode = .center
			labelNode.fontSize = maxRadius/10
			labelNode.fontColor = .white
			self.labelNode = labelNode
			rootNode.addChild(labelNode)

			rootNode.position = resourceFountainComponent.position
			setLabelText()
		}

		rootNode.alpha = 0
		OctopusKit.shared.currentScene?.addChild(rootNode)
		rootNode.run(SKAction.fadeIn(withDuration: 0.25))
	}
	
	func setLabelText() {
		if let resourceFountainComponent = entity?.component(ofType: ResourceFountainComponent.self) {
			labelNode.text = "\(Int(resourceFountainComponent.targetAlgaeSupply).formatted)"
		}
	}
	
	override func update(deltaTime seconds: TimeInterval) {
		if let frame = OctopusKit.shared.currentScene?.currentFrameNumber, frame.isMultiple(of: 20) {
			setLabelText()
		}
	}
	
	override func willRemoveFromEntity() {
		rootNode.run(SKAction.fadeOut(withDuration: 0.25)) {
			self.rootNode.removeFromParent()
		}
	}
}

