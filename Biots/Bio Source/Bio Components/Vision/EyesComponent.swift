//
//  EyesComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/15/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class EyesComponent: OKComponent {
    
	let rootNode = SKNode()

    override var requiredComponents: [GKComponent.Type]? {
		[SpriteKitComponent.self]
    }
	
	override func didAddToEntity() {
		rootNode.alpha = 0
		entityNode?.addChild(rootNode)
		rootNode.run(SKAction.fadeIn(withDuration: 0.25))
	}
	
	override func willRemoveFromEntity() {
		rootNode.run(SKAction.fadeOut(withDuration: 0.25)) {
			self.rootNode.removeFromParent()
		}
	}
	
	override init() {
						
		for angle in Constants.EyeVector.eyeAngles {
			for offset in Constants.EyeVector.refinerAngles {

//				print("angle: \(angle.degrees.formattedTo2Places), offset: \(offset.degrees.formattedTo2Places), eye angle: \((angle + offset).degrees.formattedTo2Places)")
				
				let rayStart = CGPoint.zero
				let rayEnd = rayStart + CGPoint(angle: angle + offset) * Constants.EyeVector.rayDistance

				let path = CGMutablePath()
				let node = SKShapeNode()
				node.lineWidth = 0.001 * Constants.Environment.worldRadius
				node.position = .zero
				node.lineCap = .round
				node.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: offset == 0 ? 0.5 : 0.25)
				node.isAntialiased = false
				path.move(to: rayStart)
				path.addLine(to: rayEnd)
				node.path = path
				
				rootNode.addChild(node)
			}
		}

		super.init()
	}
		
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

