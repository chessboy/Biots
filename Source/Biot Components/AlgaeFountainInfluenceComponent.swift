//
//  AlgaeFountainInfluenceComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/21/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class AlgaeFountainInfluenceComponent: OKComponent {
    
	let rootNode = SKNode()

    override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		AlgaeFountainInfluenceComponent.self
	]}
	
	override func didAddToEntity() {
		
		if let algaeFountainComponent = entity?.component(ofType: AlgaeFountainComponent.self) {
			
			let maxRadius = algaeFountainComponent.maxRadius
			let minRadius = algaeFountainComponent.minRadius

			let influenceNode = SKShapeNode.arcOfRadius(radius: maxRadius, startAngle: 0, endAngle: 2*π)
			influenceNode.lineWidth = maxRadius - minRadius
			influenceNode.strokeColor = SKColor.green.withAlpha(0.25)
			influenceNode.fillColor = .clear
			rootNode.addChild(influenceNode)
			rootNode.position = algaeFountainComponent.position
		}

		rootNode.alpha = 0
		OctopusKit.shared.currentScene?.addChild(rootNode)
		rootNode.run(SKAction.fadeIn(withDuration: 0.25))
	}
	
	override func willRemoveFromEntity() {
		rootNode.run(SKAction.fadeOut(withDuration: 0.25)) {
			self.rootNode.removeFromParent()
		}
	}
}

