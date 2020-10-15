//
//  EntityStatsComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/15/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class EntityStatsComponent: OKComponent {
	
	var statsNode: StatsNode!
	
	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self
	]}
	
	override init() {
		statsNode = StatsNode(bodyRadius: Constants.Biot.radius, fontSize: 70)
		statsNode.zPosition = Constants.ZeeOrder.biot + 10
		super.init()
	}
	
	override func didAddToEntity() {
		statsNode.alpha = 0
		entityNode?.addChild(statsNode)
		statsNode.run(SKAction.fadeIn(withDuration: 0.125))
		if let cameraScale = OctopusKit.shared.currentScene?.camera?.xScale {
			let scale = (0.2 * cameraScale).clamped(0.3, 0.75)
			statsNode.setScale(scale)
		}
	}
	
	override func willRemoveFromEntity() {
		statsNode.run(SKAction.fadeOut(withDuration: 0.25)) {
			self.statsNode.removeFromParent()
		}
	}

	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
