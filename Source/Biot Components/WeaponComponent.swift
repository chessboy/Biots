//
//  WeaponComponent.swift
//  OctopusKitQuickstart
//
//  Created by Robert Silverman on 12/5/18.
//

import SpriteKit
import OctopusKit

final class WeaponComponent: OKComponent {
	
	var isFeeding = false
	
	override func update(deltaTime seconds: TimeInterval) {
		predate()
	}
	
	func predate() {
		isFeeding = false

		guard let biotComponent = coComponent(BiotComponent.self), biotComponent.genome.isOmnivore,
			  let weaponIntensity = coComponent(BrainComponent.self)?.inference.constrainedWeaponAverage, weaponIntensity > 0,
			  let node = entityNode,
			  let physicsWorld = OctopusKit.shared.currentScene?.physicsWorld
		else { return }

		let radius = Constants.Biot.radius * (biotComponent.isMature ? 1 : 0.5)
		let angle = node.zRotation
		let rayDistance = weaponIntensity * Constants.Biot.spikeLength * (biotComponent.isMature ? 1 : 0.5)
		let rayStart = node.position + (CGPoint(angle: angle) * (radius - 1))
		let rayEnd = rayStart + (CGPoint(angle: angle) * rayDistance)

//		let path = CGMutablePath()
//		let tracerNode = SKShapeNode()
//		tracerNode.lineWidth = 2
//		tracerNode.strokeColor = SKColor.yellow.withAlpha(0.5)
//		tracerNode.zPosition = 200
//		path.move(to: rayStart)
//		path.addLine(to: rayEnd)
//		tracerNode.path = path
//		OctopusKit.shared?.currentScene?.addChild(tracerNode)
//		tracerNode.run(SKAction.fadeOut(withDuration: 0.4))
	
		physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd, using: { (body, hitPoint, normal, stop) in

			if body.categoryBitMask & Constants.CategoryBitMasks.biot > 0 {
				
				stop[0] = true
				if let preyBiot = OctopusKit.shared?.currentScene?.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == body }).first?.component(ofType: BiotComponent.self), let preyArmor = preyBiot.coComponent(BrainComponent.self)?.inference.armor.average.cgFloat {
					
					self.isFeeding = true
					
					let energyExtracted: CGFloat = Constants.Algae.bite / 10
					let armorDampendedImpact = energyExtracted * (1 - preyArmor)
					
					// omnivore gains energy and hydration
					biotComponent.incurEnergyChange(armorDampendedImpact, showEffect: true)
					biotComponent.incurHydrationChange(armorDampendedImpact)

					// prey loses some energy and some hydration
					preyBiot.incurEnergyChange(-armorDampendedImpact/2, showEffect: true)
					preyBiot.incurHydrationChange(-armorDampendedImpact/2)
				}
			}
		})
	}

}

