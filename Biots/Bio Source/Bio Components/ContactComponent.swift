//
//  ContactComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/15/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class ContactComponent: PhysicsContactComponent {
      
	override func didBegin(_ contact: SKPhysicsContact, in scene: OKScene?) {
				
		var cellCandidateA, cellCandidateB: CellComponent?

		if contact.bodyA.categoryBitMask == Constants.CategoryBitMasks.cell {
			cellCandidateA = scene?.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == contact.bodyA }).first?.component(ofType: CellComponent.self)
		}
		
		if contact.bodyB.categoryBitMask == Constants.CategoryBitMasks.cell {
			cellCandidateB = scene?.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == contact.bodyB }).first?.component(ofType: CellComponent.self)
		}

		if let cellA = cellCandidateA, let cellB = cellCandidateB {
			cellsCollided(cellA: cellA, cellB: cellB)
			return
		}

		guard let cell = cellCandidateA ?? cellCandidateB else {
			OctopusKit.logForSim.add("no contact in collision is a cell!")
			return
		}

		if contact.bodyA.categoryBitMask == Constants.CategoryBitMasks.wall {
			
			let armor = cell.coComponent(BrainComponent.self)?.inference.armor.average.cgFloat ?? 0
			let exposure = 1 - armor

			if armor < 1 {
				cell.incurStaminaChange(Constants.Cell.collisionDamage * exposure, showEffect: true)
			}
			return
		}
		
		//OctopusKit.logForSim.add("no contact pairs could be determined!")
	}
	
	func cellsCollided(cellA: CellComponent, cellB: CellComponent) {
		let impact = Constants.Cell.collisionDamage
		
		let armorA = cellA.coComponent(BrainComponent.self)?.inference.armor.average.cgFloat ?? 0
		let exposureA = 1 - armorA
		let armorB = cellB.coComponent(BrainComponent.self)?.inference.armor.average.cgFloat ?? 0
		let exposureB = 1 - armorB

		cellA.incurStaminaChange(impact/2 * exposureA, showEffect: true)
		cellB.incurStaminaChange(impact/2 * exposureB, showEffect: true)
	}
}

