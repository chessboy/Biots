//
//  MenuComponent.swift
//  Biots
//
//  Created by Rob Silverman on 11/8/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class MenuComponent: OctopusComponent {
    
	var maskNode: SKShapeNode!
	var titleNode: SKLabelNode!
	var pointerEventComponent: PointerEventComponent
	
	init(pointerEventComponent: PointerEventComponent) {
		self.pointerEventComponent = pointerEventComponent
		super.init()
	}
	
	func toggleVisibility() {
		let isHidden = maskNode.isHidden
		
		if isHidden {
			maskNode.isHidden = false
			maskNode.alpha = 0
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
		
		let fontHeight: CGFloat = 24
		let width: CGFloat = 700
		let height: CGFloat = 600
		let padding: CGFloat = 20

		maskNode = SKShapeNode(rect: CGRect(center: .zero, size: CGSize(width: width, height: height)), cornerRadius: 20)
		maskNode.lineWidth = 0
		maskNode.isHidden = true
		maskNode.fillColor = SKColor(white: 0, alpha: 0.75)
		maskNode.zPosition = Constants.ZeeOrder.stats

		let font = OKFont(name: Constants.Font.regular, size: fontHeight, color: SKColor.white.withAlpha(0.8))
		titleNode = SKLabelNode()
		titleNode.text = "Menu Test"
		titleNode.horizontalAlignmentMode = .center
		titleNode.verticalAlignmentMode = .top
		titleNode.font = font
		titleNode.position = CGPoint(x: 0, y: height/2 - padding)
		maskNode.addChild(titleNode)
		
		// todo: create ButtonComponent or use one of OK's
		let buttonTestNode = SKShapeNode(rect: CGRect(center: .zero, size: CGSize(width: 300, height: 80)), cornerRadius: 10)
		buttonTestNode.fillColor = SKColor.systemBlue.withAlpha(0.5)
		buttonTestNode.position = CGPoint(x: 0, y: height/2 - (padding * 8))
		buttonTestNode.lineWidth = 0
		
		let buttonTestLabelNode = SKLabelNode()
		buttonTestLabelNode.text = "Button Test"
		buttonTestLabelNode.horizontalAlignmentMode = .center
		buttonTestLabelNode.verticalAlignmentMode = .center
		buttonTestLabelNode.font = font
		buttonTestNode.addChild(buttonTestLabelNode)
		
		maskNode.addChild(buttonTestNode)
		if let camera = coComponent(CameraComponent.self)?.camera {
			camera.addChild(maskNode)
		}
	}

	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

