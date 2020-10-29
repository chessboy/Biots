//
//  GlobalStatsComponent.swift
//  Biots
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
	var pointerEventComponent: PointerEventComponent
	
	init(pointerEventComponent: PointerEventComponent) {
		self.pointerEventComponent = pointerEventComponent
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateStats(_ text: String) {
		textNode.text = text
	}
	
	func setPaused(_ paused: Bool) {
		maskNode.fillColor = paused ? SKColor(red: 0.5, green: 0, blue: 0, alpha: 0.5) : SKColor(white: 0, alpha: 0.75)
	}
	
	func toggleVisibility() {
		let isHidden = maskNode.isHidden
		
		if isHidden {
			maskNode.isHidden = false
			maskNode.alpha = 0
			maskNode.run(.fadeIn(withDuration: 0.15))
			maskNode.run(.fadeIn(withDuration: 0.15))
		} else {
			maskNode.run(.fadeOut(withDuration: 0.25)) {
			   self.maskNode.isHidden = true
			}
		}
	}
	
	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		CameraComponent.self
	]}
	
	override func didAddToEntity(withNode node: SKNode) {
		
		let height: CGFloat = 80
		let fontHeight: CGFloat = 24

		let parentFrame = node.frame
		let rect = CGRect(x: parentFrame.minX, y: 0, width: parentFrame.width, height: height)
		maskNode = SKShapeNode(rect: rect)
		maskNode.lineWidth = 0
		maskNode.fillColor = SKColor(white: 0, alpha: 0.75)
		maskNode.position = CGPoint(x: 0, y: parentFrame.origin.y)
		maskNode.zPosition = Constants.ZeeOrder.stats

		let font = OKFont(name: Constants.Font.regular, size: fontHeight, color: SKColor.white.withAlpha(0.8))
    	textNode = SKLabelNode()
		textNode.text = "Starting up..."
		textNode.horizontalAlignmentMode = .center
		textNode.verticalAlignmentMode = .center
		textNode.font = font
		textNode.position = CGPoint(x: 0, y: height/2)
		
		maskNode.addChild(textNode)
		
		if let camera = coComponent(CameraComponent.self)?.camera {
			camera.addChild(maskNode)
		}
	}
}

extension GlobalStatsComponent {
	static func create() {
		
	}
}
