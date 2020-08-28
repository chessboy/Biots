//
//  GlobalStatsComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class GlobalStatsComponent: OKComponent, OKUpdatableComponent {
    
	var textNode: SKLabelNode!
	var maskNode: SKShapeNode!

	func updateStats(_ text: String) {
		textNode.text = text
	}
	
	func setPaused(_ paused: Bool) {
		maskNode.fillColor = paused ? SKColor(red: 0.5, green: 0, blue: 0, alpha: 0.5) : SKColor(white: 0, alpha: 0.75)
	}
	
    override var requiredComponents: [GKComponent.Type]? {
		[SpriteKitComponent.self, CameraComponent.self]
    }
    
    override func didAddToEntity(withNode node: SKNode) {
		let rect = CGRect(x: -750, y: 0, width: 1500, height: 36)
		maskNode = SKShapeNode(rect: rect, cornerRadius: 18)
		maskNode.lineWidth = 0
		maskNode.fillColor = SKColor(white: 0, alpha: 0.75)
		maskNode.position = CGPoint(x: 0, y: -560)
		maskNode.zPosition = Constants.ZeeOrder.stats

		let font = OKFont(name: "Consolas", size: 20, color: .white)
		
        textNode = SKLabelNode()
		textNode.text = "Starting up..."
		textNode.font = font
		textNode.position = CGPoint(x: 0, y: 12)
		
		maskNode.addChild(textNode)
		
		if let camera = coComponent(CameraComponent.self)?.camera {
			camera.addChild(maskNode)
		}
    }
}

