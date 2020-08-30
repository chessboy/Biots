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
		var wallCandidateA, wallCandidateB: BoundaryComponent?

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

		// cell collided with something else, check wall

		if contact.bodyA.categoryBitMask == Constants.CategoryBitMasks.wall {
			wallCandidateA = scene?.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == contact.bodyA }).first?.component(ofType: BoundaryComponent.self)
		}
		
		if contact.bodyB.categoryBitMask == Constants.CategoryBitMasks.wall {
			wallCandidateB = scene?.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == contact.bodyB }).first?.component(ofType: BoundaryComponent.self)
		}
		
		if let wall = wallCandidateA ?? wallCandidateB {
			cellAndWallCollided(cell: cell, wall: wall)
			return
		}
		
		//OctopusKit.logForSim.add("no contact pairs could be determined!")
	}
	
	func cellsCollided(cellA: CellComponent, cellB: CellComponent) {
		let impact = Constants.Cell.collisionDamage
		cellA.incurStaminaChange(impact/2, showEffect: true)
		cellB.incurStaminaChange(impact/2, showEffect: true)
	}
			
	func cellAndWallCollided(cell: CellComponent, wall: BoundaryComponent) {
		//print("cell hit wall")
		//cell.collidedWithWall()
		cell.incurStaminaChange(Constants.Cell.collisionDamage, showEffect: true)
	}
}

