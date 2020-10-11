//
//  AlgaeFountainComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
import OctopusKit

final class ResourceFountainComponent: OKComponent, OKUpdatableComponent {
	
	var position: CGPoint = .zero
	var minRadius: CGFloat = 0
	var maxRadius: CGFloat = 0
	var targetAlgaeSupply: CGFloat = 0
	var frame = Int.random(100)

	var algaeEntities: [OKEntity] = []
	var waterEntities: [OKEntity] = []

	init(position: CGPoint = .zero, minRadius: CGFloat = 100, maxRadius: CGFloat, targetAlgaeSupply: CGFloat) {
		self.position = position
		self.minRadius = minRadius
		self.maxRadius = maxRadius
		self.targetAlgaeSupply = targetAlgaeSupply

		super.init()
	}
	
	func createWaterEntity() -> OKEntity {

		let radius = CGFloat.random(in: 40...200)
		let position = CGPoint.randomAngle * CGFloat.random(in: 0...Constants.Env.worldRadius * 0.8)
		let water = WaterSourceComponent.create(radius: radius, position: position)
		
		if let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideSpriteNodes {
			water.node?.isHidden = hideNode
		}
		
		return water
	}
		
	func createAlgaeEntity(energy: CGFloat) -> OKEntity {
		
		let position = algaeEntities.count > 0 && Int.oneChanceIn(3) ? pointNextToExistingAlgaeSource :
			waterEntities.count > 0 && Int.oneChanceIn(5) ? pointNextToExistingWaterSource : randomPoint
		
		let algae = AlgaeComponent.create(position: position, energy: energy)
		algae.addComponent(RelayComponent(for: self))
		if let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideSpriteNodes {
			algae.node?.isHidden = hideNode
		}
		algaeEntities.append(algae)
		
		return algae
	}
		
	func removeAlgaeEntity(algaeEntity: OKEntity) {
		algaeEntities = algaeEntities.filter({ $0 !== algaeEntity })
	}

	var randomPoint: CGPoint {
		let distance = minRadius + (CGFloat.random(in: 0..<1) * (maxRadius - minRadius))
		return position + CGPoint(angle: CGFloat.random(in: 0..<2*π)) * distance
	}
	
	var pointNextToExistingAlgaeSource: CGPoint {
		
		guard algaeEntities.count > 0 else { return .zero }
		
		let index = Int.random(algaeEntities.count)
		let randomAlgaeEntity = algaeEntities[index]
		if let position = randomAlgaeEntity.node?.position {
			return position + CGPoint(angle: CGFloat.random(in: 0..<2*π) * 20)
		}
		
		return .zero
	}
	
	var pointNextToExistingWaterSource: CGPoint {
		
		guard waterEntities.count > 0 else { return .zero }
		
		let index = Int.random(waterEntities.count)
		let randomWaterEntity = waterEntities[index]
		if let position = randomWaterEntity.node?.position {
			return position + CGPoint(angle: CGFloat.random(in: 0..<2*π) * 80)
		}
		
		return .zero
	}

	var currentAlgaeSupply: CGFloat {
		var sum: CGFloat = 0.0
		algaeEntities.forEach({ sum += $0.component(ofType: AlgaeComponent.self)?.energy ?? 0 })
		return sum
	}
	
	override func update(deltaTime seconds: TimeInterval) {
		
		frame += 1

		guard frame.isMultiple(of: 10) else {
			return
		}
		
//		if waterEntities.count < Constants.Env.waterCount, let scene = OctopusKit.shared?.currentScene {
//			let water = createWaterEntity()
//			waterEntities.append(water)
//			scene.addEntity(water)
//		}
		
		if currentAlgaeSupply > targetAlgaeSupply * 1.1 {
			for _ in 1...4 {
				if let algae = algaeEntities.randomElement(), let algaeComponent = algae.component(ofType: AlgaeComponent.self) {
					algaeComponent.energy = 0
					algaeComponent.bitten()
				}
			}
		}
		else if currentAlgaeSupply < targetAlgaeSupply * 0.99 {
			for _ in 1...4 {
				if let scene = OctopusKit.shared?.currentScene {
					let energy = Constants.Algae.bite * Int.random(min: 2, max: 5).cgFloat
					scene.addEntity(createAlgaeEntity(energy: energy))
				}
			}
		}
	}
	
	public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ResourceFountainComponent {
	
	static func createFountain(position: CGPoint = .zero, minRadius: CGFloat = 100, maxRadius: CGFloat, targetAlgaeSupply: CGFloat) -> OKEntity {
		
		return OKEntity(name: "resourceFountain", components: [
			ResourceFountainComponent(position: position, minRadius: minRadius, maxRadius: maxRadius, targetAlgaeSupply: targetAlgaeSupply)
		])
	}
}
