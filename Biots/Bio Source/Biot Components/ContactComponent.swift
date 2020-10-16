//
//  ContactComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/15/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class ContactComponent: PhysicsContactComponent {
	  
	override func didBegin(_ contact: SKPhysicsContact, in scene: OKScene?) {
				
		var biotCandidateA, biotCandidateB: BiotComponent?

		if contact.bodyA.categoryBitMask == Constants.CategoryBitMasks.biot {
			biotCandidateA = scene?.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == contact.bodyA }).first?.component(ofType: BiotComponent.self)
		}
		
		if contact.bodyB.categoryBitMask == Constants.CategoryBitMasks.biot {
			biotCandidateB = scene?.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == contact.bodyB }).first?.component(ofType: BiotComponent.self)
		}

		if let biotA = biotCandidateA, let biotB = biotCandidateB {
			biotsCollided(biotA: biotA, biotB: biotB)
			return
		}

		guard let biot = biotCandidateA ?? biotCandidateB else {
			OctopusKit.logForSim.add("no contact in collision is a biot!")
			return
		}

		if contact.bodyA.categoryBitMask == Constants.CategoryBitMasks.wall {
			
			let armor = biot.coComponent(BrainComponent.self)?.inference.armor.average.cgFloat ?? 0
			let exposure = 1 - armor

			if armor < 1 {
				biot.incurStaminaChange(Constants.Biot.collisionDamage * exposure, showEffect: true)
			}
			return
		}
		
		//OctopusKit.logForSim.add("no contact pairs could be determined!")
	}
	
	func biotsCollided(biotA: BiotComponent, biotB: BiotComponent) {
		let impact = Constants.Biot.collisionDamage/2
		
		let armorA = biotA.coComponent(BrainComponent.self)?.inference.armor.average.cgFloat ?? 0
		let exposureA = 1 - armorA
		let armorB = biotB.coComponent(BrainComponent.self)?.inference.armor.average.cgFloat ?? 0
		let exposureB = 1 - armorB

		biotA.incurStaminaChange(impact * exposureA, showEffect: true)
		biotB.incurStaminaChange(impact * exposureB, showEffect: true)
	}
}
