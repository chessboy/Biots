//
//  CellComponent.swift
//  BioGenesis
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class CellComponent: OKComponent, OKUpdatableComponent {
				
	var genome: Genome
	var expired = false
	
	var foodEnergy: CGFloat
	var hydration: CGFloat
	var stamina: CGFloat = 1
	
	var cumulativeFoodEnergy: CGFloat = 0
	var cumulativeHydration: CGFloat = 0
	var cumulativeDamage: CGFloat = 0

	var age: CGFloat = 0
	var lastSpawnedAge: CGFloat = 0
	var lastPregnantAge: CGFloat = 0
	var lastInteractedAge: CGFloat = 0
	var lastBlinkAge: CGFloat = 0
	
	var spawnCount: Int = 0
	var isInteracting = false
	var matedCount = 0

	var healthNode: SKShapeNode!
	var speedNode: SKShapeNode!
	var armorNode: SKShapeNode!
	var eyeNodes: [SKShapeNode] = []

	var visionNode: SKNode!
	var retinaNodes: [RetinaNode] = []
	var onTopOfFoodRetinaNode: RetinaNode!
	var onTopOfWaterRetinaNode: RetinaNode!
	var thrusterNode: ThrusterNode!

	var matingGenome: Genome?	
	
	var isPregnant: Bool {
		return matingGenome != nil
	}
	
	var canMate: Bool {
		return !expired && !isPregnant && age >= Constants.Cell.matureAge && health >= Constants.Cell.mateHealth
	}

	var maximumEnergy: CGFloat {
		return isPregnant ? Constants.Cell.maximumFoodEnergy * 2 : Constants.Cell.maximumFoodEnergy
	}

	var health: CGFloat {
		let foodEnergyRatio = foodEnergy/maximumEnergy
		let hydrationRatio = hydration/Constants.Cell.maximumHydration
		let health = min(foodEnergyRatio, hydrationRatio)
		return health - (1-stamina)
	}
	
	var bodyColor: SKColor {
		return brainComponent?.inference.color.average.skColor ?? .black
	}

	var frame = Int.random(100)

	lazy var brainComponent = coComponent(BrainComponent.self)
	lazy var globalDataComponent = coComponent(GlobalDataComponent.self)
	lazy var visionComponent = coComponent(VisionComponent.self)

	init(genome: Genome) {
		self.genome = genome
		self.foodEnergy = Constants.Cell.initialFoodEnergy
		self.hydration = Constants.Cell.initialHydration
		super.init()
	}

	func startInteracting() {
		isInteracting = true
		lastInteractedAge = age
	}
	
	func stopInteracting() {
		isInteracting = false
		lastInteractedAge = age
	}

	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		PhysicsComponent.self,
		ContactComponent.self,
		VisionComponent.self,
		NeuralNetComponent.self,
		BrainComponent.self
	]}
	
	override func didAddToEntity() {
				
		if let node = entityNode as? SKShapeNode {
			let scales = 5
			node.setScale(0.2)
			var actions: [SKAction] = []
			for growth in 2...scales {
				let scale: CGFloat = growth.cgFloat/scales.cgFloat
				actions.append(.wait(forDuration: 0.5))
				actions.append(.scale(to: scale, duration: 0.15))
			}
			
			let sequence = SKAction.sequence(actions)
			node.run(sequence)
		}
		
		let showVision = globalDataComponent?.showCellVision ?? false
		
		eyeNodes.forEach({ eyeNode in
			eyeNode.isHidden = showVision
		})
	}
		
	func incurEnergyChange(_ amount: CGFloat, showEffect: Bool = false) {
		if amount > 0 {
			cumulativeFoodEnergy += amount
		}
		foodEnergy += amount
		foodEnergy = foodEnergy.clamped(to: 0...maximumEnergy)
		if showEffect, !healthNode.isHidden {
			updateHealthNode()
			contactEffect(impact: amount)
		}
	}
	
	func incurHydrationChange(_ amount: CGFloat) {
		if amount > 0 {
			cumulativeHydration += amount
		}
		hydration += amount
		hydration = hydration.clamped(to: 0...Constants.Cell.maximumHydration)
	}
	
	func incurStaminaChange(_ amount: CGFloat, showEffect: Bool = false) {
		guard abs(amount) != 0 else { return }
		
		if amount > 0 {
			cumulativeDamage += amount
		}
		stamina -= amount
		stamina = stamina.clamped(to: 0...1)
		if showEffect {
			updateHealthNode()
			contactEffect(impact: amount)
		}
	}
		
	func kill() {
		foodEnergy = 0
		stamina = 0
	}
	
	func cellAndAlgaeCollided(algae: AlgaeComponent) {
				
		let bite: CGFloat = Constants.Algae.bite
		guard foodEnergy + bite/4 < maximumEnergy else { return }
		
		incurEnergyChange(bite, showEffect: true)

		algae.energy -= bite
		if algae.energy < bite {
			algae.energy = 0
		}
		algae.bitten()
	}

	func cellAndWaterCollided() {
		let sip: CGFloat = Constants.Water.sip
		guard hydration + sip/8 < Constants.Cell.maximumHydration else { return }
		incurHydrationChange(sip)
	}

	struct BodyContact {
		var when: TimeInterval
		var body: SKPhysicsBody
		
		mutating func updateWhen(when: TimeInterval) {
			self.when = when
		}
	}
	
	var contactedAlgaeComponents: [BodyContact] = []
	var onTopOfFood = false
	var contactedWaterComponents: [BodyContact] = []
	var onTopOfWater = false

	func checkResourceContacts() {
		let now = Date().timeIntervalSince1970

		if frame.isMultiple(of: 30) {
			//let countAlgae = contactedAlgaeComponents.count
			contactedAlgaeComponents = contactedAlgaeComponents.filter({ now - $0.when <= Constants.Algae.timeBetweenBites })
			//print("algae body purge: old count: \(countAlgae), new count: \(contactedAlgaeComponents.count)")
			
			//let countWater = contactedWaterComponents.count
			contactedWaterComponents = contactedWaterComponents.filter({ now - $0.when <= Constants.Water.timeBetweenSips })
			//print("water body purge: old count: \(countWater), new count: \(contactedWaterComponents.count)")
		}
		
		onTopOfFood = false
		onTopOfWater = false

		if let scene = OctopusKit.shared.currentScene, let bodies = entityNode?.physicsBody?.allContactedBodies(), bodies.count > 0 {
			for body in bodies {
				
				if body.categoryBitMask == Constants.CategoryBitMasks.algae {
					if let algae = scene.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == body }).first?.component(ofType: AlgaeComponent.self), algae.energy > 0 {

						onTopOfFood = true
						var contact = contactedAlgaeComponents.filter({ $0.body == body }).first
						
						if contact == nil {
							//print("algae added at \(now), ate algae energy: \(algae.energy.formattedTo2Places)")
							contactedAlgaeComponents.append(BodyContact(when: now, body: body))
							cellAndAlgaeCollided(algae: algae)
						}
						else if now - contact!.when > Constants.Algae.timeBetweenBites {
							//print("algae found at: \(contact!.when), now: \(now), delta: \(now - contact!.when), ate algae energy: \(algae.energy.formattedTo2Places)")
							contact!.updateWhen(when: now)
							cellAndAlgaeCollided(algae: algae)
						}
					}
				}
				else if body.categoryBitMask == Constants.CategoryBitMasks.water {
					
					onTopOfWater = true
					var contact = contactedWaterComponents.filter({ $0.body == body }).first
					
					if contact == nil {
						//print("water added at \(now), drank water")
						contactedWaterComponents.append(BodyContact(when: now, body: body))
						cellAndWaterCollided()
					}
					else if now - contact!.when > Constants.Water.timeBetweenSips {
						//print("water found at: \(contact!.when), now: \(now), delta: \(now - contact!.when), drank water")
						contact!.updateWhen(when: now)
						cellAndWaterCollided()
					}
				}
			}
		}
	}
		
	func blink() {
		guard age - lastBlinkAge > 60 else { return }
		lastBlinkAge = age
		eyeNodes.forEach({ eyeNode in
			eyeNode.run(SKAction.bulge(xScale: 0.05, yScale: 0.85, scalingDuration: 0.075, revertDuration: 0.125)) {
				eyeNode.yScale = 0.85
			}
		})
	}
		
	override func update(deltaTime seconds: TimeInterval) {
		
		guard !expired else { return }
		age += 1
				
		blink()
		checkResourceContacts()
		showStats()
		
		// check old age or malnutrition
		if age >= Constants.Cell.maximumAge || health <= 0 {
			expire()
		}
		
		// update visual indicators
		updateVisionNode()
		updateHealthNode()
		updateThrusterNode()
		
		// self-replication (sexual reproduction not supported yet)
		if frame.isMultiple(of: 10) {
			if !isPregnant, canMate, age - lastSpawnedAge > Constants.Cell.gestationAge {
				mated(otherGenome: genome)
			}
		}
		
		// check spawning
		if isPregnant, age - lastPregnantAge > Constants.Cell.gestationAge, health >= Constants.Cell.spawnHealth {
			spawnChildren()
			lastSpawnedAge = age
		}

		frame += 1
	}
	
	func expire() {
		if let scene = OctopusKit.shared.currentScene as? WorldScene, let entity = self.entity, let node = entityNode {
			expired = true
			node.run(.group([.fadeOut(withDuration: 0.2), SKAction.scale(to: 0.1, duration: 0.2)])) {
				if scene.trackedEntity == entity {
					scene.trackedEntity = nil
				}
				scene.removeEntityOnNextUpdate(entity)
				
				if node.position.distance(to: .zero) < Constants.Env.worldRadius * 0.5, let fountainComponent = self.coComponent(ResourceFountainComponent.self) {
					let algae = fountainComponent.createAlgaeEntity(energy: Constants.Algae.bite * 5)
					if let algaeComponent = algae.component(ofType: AlgaeComponent.self) {
						if let algaeNode = algaeComponent.coComponent(ofType: SpriteKitComponent.self)?.node, let physicsBody = algaeNode.physicsBody {
							algaeNode.position = node.position
							physicsBody.velocity = node.physicsBody?.velocity ?? .zero
							physicsBody.angularVelocity = node.physicsBody?.angularVelocity ?? .zero
							scene.addEntity(algae)
						}
					}
				}
			}
		}
	}

	func updateHealthNode() {
		guard frame.isMultiple(of: 5) else { return }
		
		let showingHealth = !healthNode.isHidden
		let showHealth = globalDataComponent?.showCellHealth ?? false
		
		if !showingHealth, showHealth {
			healthNode.alpha = 0
			healthNode.isHidden = false
			healthNode.run(.fadeIn(withDuration: 0.2))
		}
		else if showingHealth, !showHealth {
			healthNode.run(.fadeOut(withDuration: 0.1)) {
				self.healthNode.isHidden = true
				self.healthNode.alpha = 0
			}
		}

		if showHealth {
			let intenstity = health
			healthNode.fillColor = SKColor(red: 1 - intenstity, green: intenstity, blue: 0, alpha: 1)
		}
	}
		
	// display visual sensors
	func updateVisionNode() {
		guard frame.isMultiple(of: 2) else { return }
				
		let showingVision = !visionNode.isHidden
		let showVision = globalDataComponent?.showCellVision ?? false
		
		if !showingVision, showVision {
			eyeNodes.forEach({ eyeNode in
				eyeNode.run(.fadeOut(withDuration: 0.1), completion: {
					eyeNode.isHidden = true
				})
			})
			
			visionNode.alpha = 0
			visionNode.isHidden = false
			visionNode.run(.fadeIn(withDuration: 0.2))
		}
		else if showingVision, !showVision {

			eyeNodes.forEach({ eyeNode in
				eyeNode.run(.fadeIn(withDuration: 0.1), completion: {
					eyeNode.isHidden = false
				})
			})

			visionNode.run(.fadeOut(withDuration: 0.1)) {
				self.visionNode.isHidden = true
				self.visionNode.alpha = 0
			}
		}

		if showingVision {
			for angle in Constants.Vision.eyeAngles {
				if let retinaNode = retinaNodes.filter({ $0.angle == angle }).first {
					var color: SKColor = .black
					if let angleVision = visionComponent?.visionMemory.filter({ $0.angle == angle }).first {
						color = angleVision.runningColorVector.average.skColor
						retinaNode.zPosition = Constants.ZeeOrder.cell + color.brightnessComponent
					}
					retinaNode.strokeColor = color
				}
			}
			
			if let onTopOfFoodAverage = brainComponent?.senses.onTopOfFood.average {
				let color = SKColor(red: 0, green: onTopOfFoodAverage.cgFloat, blue: 0, alpha: 1)
				onTopOfFoodRetinaNode.strokeColor = color
			}
			
			if let onTopOfFWaterAverage = brainComponent?.senses.onTopOfWater.average {
				let color = SKColor(red: 0, green: onTopOfFWaterAverage.cgFloat, blue: onTopOfFWaterAverage.cgFloat, alpha: 1)
				onTopOfWaterRetinaNode.strokeColor = color
			}
		}
	}
	
	func updateThrusterNode() {
		
		guard frame.isMultiple(of: 2) else { return }
		
		let showingThrust = !thrusterNode.isHidden
		let showThrust = globalDataComponent?.showCellThrust ?? false
		
		if !showingThrust, showThrust {
			thrusterNode.alpha = 0
			thrusterNode.isHidden = false
			thrusterNode.run(.fadeIn(withDuration: 0.2))
			speedNode.alpha = 0
			speedNode.isHidden = false
			armorNode.alpha = 0
			armorNode.isHidden = false
		}
		else if showingThrust, !showThrust {
			thrusterNode.run(.fadeOut(withDuration: 0.1)) {
				self.thrusterNode.isHidden = true
				self.thrusterNode.alpha = 0
			}
			speedNode.run(.fadeOut(withDuration: 0.1)) {
				self.speedNode.alpha = 0
				self.speedNode.isHidden = false
			}
			armorNode.run(.fadeOut(withDuration: 0.1)) {
				self.armorNode.alpha = 0
				self.armorNode.isHidden = false
			}
		}

		if showThrust,
		   let thrust = brainComponent?.inference.thrust.average,
		   let speedBoost = brainComponent?.inference.speedBoost.average,
		   let armor = brainComponent?.inference.armor.average {
			thrusterNode.update(leftThrustIntensity: thrust.dx, rightThrustIntensity: thrust.dy)
			speedNode.alpha = speedBoost.cgFloat
			armorNode.alpha = armor.cgFloat
		}
	}
	
	func showStats() {
		
		if  let statsNode = coComponent(EntityStatsComponent.self)?.statsNode {
			
			if frame.isMultiple(of: 10) {
 				if globalDataComponent?.showCellStats == true {
					
					if let cameraScale = OctopusKit.shared.currentScene?.camera?.xScale {
						let scale = (0.2 * cameraScale).clamped(0.3, 0.75)
						if statsNode.xScale != scale {
							statsNode.run(SKAction.scale(to: scale, duration: 0.2))
						}
					}
					
//					let position = entityNode?.position ?? .zero
//					let angle = ((entityNode?.zRotation ?? .zero) + π).normalizedAngle
//					let theta = atan2(position.y, position.x).normalizedAngle
//					let angleToCenter = ((theta + angle + π).normalizedAngle / (2*π))
					
					let healthFormatted = health.formattedToPercentNoDecimal
					let energyFormatted = (foodEnergy/maximumEnergy).formattedToPercentNoDecimal
					let hydrationFormatted = (hydration/Constants.Cell.maximumHydration).formattedToPercentNoDecimal
					let staminaFormatted = stamina.formattedToPercentNoDecimal
					var armorDescr = "-none-"
					if let inference = brainComponent?.inference {
						armorDescr = inference.armor.average.formattedTo2Places
					}
					
					statsNode.setLineOfText("h: \(healthFormatted), e: \(energyFormatted), w: \(hydrationFormatted), s: \(staminaFormatted)", for: .line1)
					statsNode.setLineOfText("gen: \(genome.generation) | age: \((age/Constants.Cell.maximumAge).formattedToPercentNoDecimal)", for: .line2)
					statsNode.setLineOfText("spawn: \(spawnCount), cf: \(cumulativeFoodEnergy.formattedNoDecimal), cw: \(cumulativeHydration.formattedNoDecimal), cd: \(cumulativeDamage.formatted), arm: \(armorDescr)", for: .line3)
					statsNode.updateBackgroundNode()
				}
			}
			if let node = entityNode {
				statsNode.zRotation = 2*π - node.zRotation
			}
		}
	}

	func spawnChildren(selfReplication: Bool = false) {
		guard let node = entityNode as? SKShapeNode, let scene = OctopusKit.shared.currentScene, let matingGenome = matingGenome else {
			return
		}

		if let worldScene = scene as? WorldScene, let worldComponent = worldScene.entity?.component(ofType: WorldComponent.self), worldComponent.currentCells.count >= Constants.Env.maximumCells {
			let clonedGenome = Genome(parent: matingGenome)
			worldComponent.addUnbornGenome(clonedGenome)
			self.matingGenome = nil
			self.lastPregnantAge = 0
			node.run(SKAction.scale(to: 1, duration: 0.25))
			return
		}
		
		foodEnergy = foodEnergy / 4
		hydration = Constants.Cell.initialHydration
		incurStaminaChange(0.05)
		
		spawnCount += 1
		
		let selfReplicationSpawn = [(genome, -π/8), (genome, π/8)]
		let standardSpawn =  [(genome, -π/8), (matingGenome, π/8)]

		let spawn = selfReplication ? selfReplicationSpawn : standardSpawn
		
		for (parentGenome, angle) in spawn {
			
			let position = node.position - CGPoint(angle: node.zRotation + angle) * Constants.Cell.radius * 2
			let clonedGenome = Genome(parent: parentGenome)
			let childCell = CellComponent.createCell(genome: clonedGenome, at: position, fountainComponent: RelayComponent(for: coComponent(ResourceFountainComponent.self)))
			childCell.node?.zRotation = node.zRotation + angle + π
			
			if globalDataComponent?.showCellStats ?? false {
				childCell.addComponent(EntityStatsComponent())
			}
			if globalDataComponent?.showCellEyeSpots ?? false {
				childCell.addComponent(EyesComponent())
			}
			//print("\(currentColor)-🥚 id: \(clonedGenome.id), gen: \(clonedGenome.generation)")
			//print(clonedGenome.jsonString)
			
			scene.run(SKAction.wait(forDuration: 0.1)) {
				scene.addEntity(childCell)
				
				if let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideSpriteNodes {
					childCell.node?.isHidden = hideNode
				}
			}
		}
		
		self.matingGenome = nil
		node.run(SKAction.scale(to: 1, duration: 0.25))
	}
	
	func mated(otherGenome: Genome) {
		guard !isPregnant else {
			return
		}
		
		matingGenome = otherGenome
		lastPregnantAge = age
		
		if let node = entityNode as? SKShapeNode {
			node.run(SKAction.scale(to: 1.25, duration: 0.25))
		}
	}
	
	func contactEffect(impact: CGFloat) {
		
		guard !healthNode.isHidden else {
			return
		}
		
		if impact > 0 {
			let pulseUp = SKAction.scale(to: 1.5, duration: 0.2)
			let pulseDown = SKAction.scale(to: 1, duration: 0.4)
			let sequence = SKAction.sequence([pulseUp, .wait(forDuration: 0.1), pulseDown])
			sequence.timingMode = .easeInEaseOut
			healthNode.run(sequence)
		}
		else {
			let pulseDown = SKAction.scale(to: 0.5, duration: 0.1)
			let pulseUp = SKAction.scale(to: 1, duration: 0.2)
			let sequence = SKAction.sequence([pulseDown, .wait(forDuration: 0.1), pulseUp])
			sequence.timingMode = .easeInEaseOut
			healthNode.run(sequence)
		}
	}
}

extension CellComponent {
		
	static func createCell(genome: Genome, at position: CGPoint, fountainComponent: RelayComponent<ResourceFountainComponent>) -> OKEntity {

		let radius = Constants.Cell.radius
		let node = SKShapeNode(circleOfRadius: radius)
		node.name = "cell"
		node.fillColor = SKColor.lightGray
		node.lineWidth = radius * 0.075
		node.strokeColor = .clear
		node.position = position
		node.zPosition = Constants.ZeeOrder.cell
		node.zRotation = CGFloat.randomAngle
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.antialiased
		
		let cellComponent = CellComponent(genome: genome)

		if Constants.Env.graphics.shadows {
			let shadowNode = SKShapeNode()
			shadowNode.path = node.path
			shadowNode.zPosition = Constants.ZeeOrder.cell - 6
			shadowNode.glowWidth = radius * 0.2
			shadowNode.strokeColor = SKColor.black.withAlpha(0.333)
			node.insertChild(shadowNode, at: 0)
		}
		
		var eyeNodes: [SKShapeNode] = []
		for angle in [-π/4.5, π/4.5] {
			let eyeNode = SKShapeNode(circleOfRadius: radius * 0.2)
			eyeNode.isHidden = true
			eyeNode.fillColor = .black
			eyeNode.strokeColor = .white
			eyeNode.yScale = 0.75
			eyeNode.lineWidth = Constants.Cell.radius * 0.1
			eyeNode.position = CGPoint(angle: angle) * radius * 0.65
			node.addChild(eyeNode)
			eyeNode.zPosition = node.zPosition + 0.2
			//eyeNode.isHidden = true
			eyeNodes.append(eyeNode)
		}
		
		let healthNode = SKShapeNode(circleOfRadius: radius * 0.25)
		healthNode.fillColor = .darkGray
		healthNode.lineWidth = radius * 0.05
		healthNode.strokeColor = .black//Constants.Colors.background
		healthNode.isAntialiased = Constants.Env.graphics.antialiased
		healthNode.isHidden = true
		healthNode.zPosition = Constants.ZeeOrder.cell + 0.1
		node.addChild(healthNode)
		
		let speedNode = SKShapeNode()
		let speedPath = CGMutablePath()
		speedPath.addArc(center: .zero, radius: radius * 1.1, startAngle: π/6, endAngle: -π/6, clockwise: true)
		speedNode.path = speedPath
		speedNode.fillColor = .clear
		speedNode.lineWidth = radius * 0.1
		speedNode.zRotation = π
		speedNode.alpha = 0
		speedNode.isHidden = true
		speedNode.lineCap = .round
		speedNode.strokeColor = .white
		speedNode.isAntialiased = Constants.Env.graphics.antialiased
		speedNode.zPosition = Constants.ZeeOrder.cell + 0.1
		node.addChild(speedNode)

		let armorNode = SKShapeNode()
		let armorPath = CGMutablePath()
		armorPath.addArc(center: .zero, radius: radius * 1.1, startAngle: -π/6 - π/24, endAngle: π/6 + π/24, clockwise: true)
		armorNode.path = armorPath
		armorNode.fillColor = .clear
		armorNode.lineWidth = radius * 0.1
		armorNode.zRotation = π
		armorNode.alpha = 0
		armorNode.isHidden = true
		armorNode.lineCap = .round
		armorNode.strokeColor = .green
		armorNode.isAntialiased = Constants.Env.graphics.antialiased
		armorNode.zPosition = Constants.ZeeOrder.cell + 0.2
		node.addChild(armorNode)

		// vision
		let visionNode = SKNode()
		visionNode.isHidden = true
		visionNode.zPosition = Constants.ZeeOrder.cell + 0.2
		node.addChild(visionNode)
		
		let retinaRadius: CGFloat = radius * 0.85
		let thickness: CGFloat = retinaRadius / 8
		let arcLength = π/8

		for angle in Constants.Vision.eyeAngles {
			let node = RetinaNode(angle: angle, radius: retinaRadius, thickness: thickness, arcLength: arcLength, forBackground: true)
			visionNode.addChild(node)
		}
		
		var retinaNodes: [RetinaNode] = []
		
		for angle in Constants.Vision.eyeAngles {
			let node = RetinaNode(angle: angle, radius: retinaRadius, thickness: thickness, arcLength: arcLength)
			retinaNodes.append(node)
			visionNode.addChild(node)
		}
		
		// food and water
		let onTopOfFoodRetinaNode = RetinaNode(angle: π, radius: radius * 0.65, thickness: thickness, arcLength: arcLength/2)
		visionNode.addChild(onTopOfFoodRetinaNode)
		
		let onTopOfWaterRetinaNode = RetinaNode(angle: π, radius: radius * 0.5, thickness: thickness, arcLength: arcLength/2)
		visionNode.addChild(onTopOfWaterRetinaNode)

		// thrusters
		let thrusterNode = ThrusterNode(radius: radius)
		thrusterNode.isHidden = true
		cellComponent.thrusterNode = thrusterNode
		node.addChild(thrusterNode)

		// physics
		let physicsBody = SKPhysicsBody(circleOfRadius: radius * 1.15)
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.cell
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.cell
		physicsBody.contactTestBitMask = Constants.ContactBitMasks.cell
		physicsBody.allowsRotation = false
		physicsBody.usesPreciseCollisionDetection = true
		physicsBody.mass = 5
		
		physicsBody.linearDamping = 1
		physicsBody.friction = 1
		
		let range = SKRange(lowerLimit: 0, upperLimit: Constants.Env.worldRadius)
		let keepInBounds = SKConstraint.distance(range, to: .zero)
		node.constraints = [keepInBounds]

		// set the nodes in the component
		cellComponent.visionNode = visionNode
		cellComponent.retinaNodes = retinaNodes
		cellComponent.onTopOfFoodRetinaNode = onTopOfFoodRetinaNode
		cellComponent.onTopOfWaterRetinaNode = onTopOfWaterRetinaNode
		cellComponent.healthNode = healthNode
		cellComponent.speedNode = speedNode
		cellComponent.armorNode = armorNode
		cellComponent.eyeNodes = eyeNodes

		return OKEntity(components: [
			SpriteKitComponent(node: node),
			PhysicsComponent(physicsBody: physicsBody),
			RelayComponent(for: OctopusKit.shared.currentScene?.sharedPhysicsEventComponent),
			RelayComponent(for: OctopusKit.shared.currentScene?.sharedPointerEventComponent),
			RelayComponent(for: OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)),
			fountainComponent,
			VisionComponent(),
			NeuralNetComponent(genome: genome),
			BrainComponent(),
			ContactComponent(),
			cellComponent
		])
	}
}
