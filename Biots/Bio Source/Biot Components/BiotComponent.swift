//
//  BiotComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/12/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class BiotComponent: OKComponent, OKUpdatableComponent {
				
	var genome: Genome
	var isExpired = false
	var isInteracting = false

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
	var matedCount = 0
	var matured = false

	var healthNode: SKNode!
	var healthDetailsNode: SKNode!
	var healthMeterNodes: [SKShapeNode] = []
	var speedNode: SKShapeNode!
	var armorNode: SKShapeNode!
	var eyeNodes: [SKShapeNode] = []
	var progressNode: ProgressNode!

	var visionNode: SKNode!
	var retinaNodes: [RetinaNode] = []
	var onTopOfFoodNode: SKShapeNode!
	var onTopOfWaterNode: SKShapeNode!
	var thrusterNode: ThrusterNode!

	var matingGenome: Genome?
	
	lazy var brainComponent = coComponent(BrainComponent.self)
	lazy var globalDataComponent = coComponent(GlobalDataComponent.self)
	lazy var visionComponent = coComponent(VisionComponent.self)

	enum HealthMeter: Int {
		case overall = 0
		case energy
		case hydration
		case stamina
	}
	
	var frame = Int.random(100)

	var isPregnant: Bool {
		return matingGenome != nil
	}
	
	var canMate: Bool {
		return !isExpired && !isPregnant && age >= Constants.Biot.matureAge && health >= Constants.Biot.mateHealth
	}

	var maximumEnergy: CGFloat {
		return isPregnant ? Constants.Biot.maximumFoodEnergy * 2 : Constants.Biot.maximumFoodEnergy
	}

	var progress: CGFloat {
		if isExpired { return 0 }
		
		if age < Constants.Biot.matureAge {
			if !matured {
				return age/(Constants.Biot.matureAge/2)
			}
			return age/Constants.Biot.matureAge
		}
		
		if !isPregnant {
			if canMate {
				return (age - lastSpawnedAge)/Constants.Biot.gestationAge
			}
			else {
				return min((age - lastSpawnedAge)/Constants.Biot.gestationAge, (health / Constants.Biot.mateHealth))
			}
		}
		else {
			// pregnant
			return min((age - lastPregnantAge)/Constants.Biot.gestationAge, (health / Constants.Biot.mateHealth))
		}
	}

	var health: CGFloat {
		let foodEnergyRatio = foodEnergy/maximumEnergy
		let hydrationRatio = hydration/Constants.Biot.maximumHydration
		let health = min(foodEnergyRatio, hydrationRatio)
		return health - (1-stamina)
	}
	
	var bodyColor: SKColor {
		return brainComponent?.inference.color.average.skColor ?? .black
	}

	init(genome: Genome) {
		self.genome = genome
		self.foodEnergy = Constants.Biot.initialFoodEnergy
		self.hydration = Constants.Biot.initialHydration
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	func startInteracting() {
		isInteracting = true
		lastInteractedAge = age
	}
	
	func stopInteracting() {
		isInteracting = false
		lastInteractedAge = age
	}

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
			node.setScale(0.2)
			node.run(SKAction.scale(to: 0.5, duration: 0.5))
		}
		
		let showVision = globalDataComponent?.showBiotVision ?? false
		
		eyeNodes.forEach({ eyeNode in
			eyeNode.isHidden = showVision
		})
		
		healthDetailsNode.isHidden = !showVision
		
//		if Constants.Env.debugMode {
//			foodEnergy = Constants.Biot.maximumFoodEnergy
//			hydration = Constants.Biot.maximumHydration
//		}
	}
		
	func incurEnergyChange(_ amount: CGFloat, showEffect: Bool = false) {
		//guard !Constants.Env.debugMode else { return }
		
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
		//guard !Constants.Env.debugMode else { return }
		if amount > 0 {
			cumulativeHydration += amount
		}
		hydration += amount
		hydration = hydration.clamped(to: 0...Constants.Biot.maximumHydration)
	}
	
	func incurStaminaChange(_ amount: CGFloat, showEffect: Bool = false) {
		//guard !Constants.Env.debugMode else { return }
		guard abs(amount) != 0 else { return }
		
		if amount > 0 {
			cumulativeDamage += amount
		}
		stamina -= amount
		stamina = stamina.clamped(to: 0...1)
		if showEffect {
			updateHealthNode()
			contactEffect(impact: -amount)
		}
	}
		
	func kill() {
		foodEnergy = 0
		hydration = 0
		stamina = 0
	}
	
	func biotAndAlgaeCollided(algae: AlgaeComponent) {
		let bite: CGFloat = Constants.Algae.bite
		guard foodEnergy + bite/4 < maximumEnergy else { return }
		
		incurEnergyChange(bite, showEffect: true)

		algae.energy -= bite
		if algae.energy < bite {
			algae.energy = 0
		}
		algae.bitten()
	}

	func biotAndWaterCollided() {
		let sip: CGFloat = Constants.Water.sip
		guard hydration + sip/8 < Constants.Biot.maximumHydration else { return }
		incurHydrationChange(sip)
	}

	struct BodyContact {
		var when: TimeInterval
		var body: SKPhysicsBody
		
		mutating func updateWhen(when: TimeInterval) {
			self.when = when
		}
	}
	
	var isOnTopOfFood = false
	var isOnTopOfWater = false
	var isImmersedInWater = false
	var contactedAlgaeComponents: [BodyContact] = []
	var contactedWaterComponents: [BodyContact] = []

	func checkResourceContacts() {

		guard let node = entityNode else { return }

		let now = Date().timeIntervalSince1970

		if frame.isMultiple(of: 30) {
			//let countAlgae = contactedAlgaeComponents.count
			contactedAlgaeComponents = contactedAlgaeComponents.filter({ now - $0.when <= Constants.Algae.timeBetweenBites })
			//print("algae body purge: old count: \(countAlgae), new count: \(contactedAlgaeComponents.count)")
			
			//let countWater = contactedWaterComponents.count
			contactedWaterComponents = contactedWaterComponents.filter({ now - $0.when <= Constants.Water.timeBetweenSips })
			//print("water body purge: old count: \(countWater), new count: \(contactedWaterComponents.count)")
		}
		
		isOnTopOfFood = false
		isOnTopOfWater = false
		isImmersedInWater = false

		if let scene = OctopusKit.shared.currentScene, let bodies = entityNode?.physicsBody?.allContactedBodies(), bodies.count > 0 {
			for body in bodies {
				
				if body.categoryBitMask == Constants.CategoryBitMasks.algae {
					if let algae = scene.entities.filter({ $0.component(ofType: PhysicsComponent.self)?.physicsBody == body }).first?.component(ofType: AlgaeComponent.self), algae.energy > 0 {

						isOnTopOfFood = true
						var contact = contactedAlgaeComponents.filter({ $0.body == body }).first
						
						if contact == nil {
							//print("algae added at \(now), ate algae energy: \(algae.energy.formattedTo2Places)")
							contactedAlgaeComponents.append(BodyContact(when: now, body: body))
							biotAndAlgaeCollided(algae: algae)
						}
						else if now - contact!.when > Constants.Algae.timeBetweenBites {
							//print("algae found at: \(contact!.when), now: \(now), delta: \(now - contact!.when), ate algae energy: \(algae.energy.formattedTo2Places)")
							contact!.updateWhen(when: now)
							biotAndAlgaeCollided(algae: algae)
						}
					}
				}
				else if body.categoryBitMask == Constants.CategoryBitMasks.water {
					
					let tailPoint = node.position + CGPoint(angle: node.zRotation + π) * Constants.Biot.radius
					if let waterNode = body.node, waterNode.contains(tailPoint) {
						isImmersedInWater = true
					}
					isOnTopOfWater = true
					var contact = contactedWaterComponents.filter({ $0.body == body }).first
					
					if contact == nil {
						//print("water added at \(now), drank water")
						contactedWaterComponents.append(BodyContact(when: now, body: body))
						biotAndWaterCollided()
					}
					else if now - contact!.when > Constants.Water.timeBetweenSips {
						//print("water found at: \(contact!.when), now: \(now), delta: \(now - contact!.when), drank water")
						contact!.updateWhen(when: now)
						biotAndWaterCollided()
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
	
	func showRipples() {
		
		guard !isInteracting, isImmersedInWater, let hideNodes = globalDataComponent?.hideSpriteNodes, !hideNodes, frame.isMultiple(of: 2), let node = entityNode as? SKShapeNode else { return }
		
		let rippleNode = SKShapeNode.arcOfRadius(radius: Constants.Biot.radius * 1.3 * node.xScale, startAngle: -π/4, endAngle: π/4)
		rippleNode.position = node.position
		rippleNode.zRotation = node.zRotation + π
		rippleNode.lineWidth = Constants.Biot.radius * 0.1 * node.xScale
		rippleNode.lineCap = .round
		rippleNode.strokeColor = SKColor.white.withAlpha(0.33)
		rippleNode.isAntialiased = Constants.Env.graphics.isAntialiased
		rippleNode.zPosition = Constants.ZeeOrder.biot - 0.1
		OctopusKit.shared.currentScene?.addChild(rippleNode)
		let duraction: TimeInterval = 0.75
		let group = SKAction.group([SKAction.scale(to: 0.2, duration: duraction), SKAction.fadeAlpha(to: 0, duration: duraction)])
		rippleNode.run(group) {
			rippleNode.removeFromParent()
		}
	}
	
	override func update(deltaTime seconds: TimeInterval) {
		
		guard !isExpired else { return }
		
		//if !Constants.Env.debugMode {
			age += 1
		//}

		if !matured, age >= Constants.Biot.matureAge / 2 {
			entityNode?.run(SKAction.scale(to: 1, duration: 0.5))
			matured = true
		}

		checkResourceContacts()
		
		// check old age or malnutrition
		if age >= Constants.Biot.maximumAge || health <= 0 {
			expire()
		}
		
		// update visual indicators
		if let hideNodes = globalDataComponent?.hideSpriteNodes, !hideNodes {
			updateVisionNode()
			updateHealthNode()
			updateThrusterNode()
			blink()
			showStats()
		}

		// self-replication (sexual reproduction not supported yet)
		if frame.isMultiple(of: 10) {
			if !isPregnant, canMate, age - lastSpawnedAge > Constants.Biot.gestationAge {
				mated(otherGenome: genome)
			}
		}
		
		// check spawning
		if isPregnant, age - lastPregnantAge > Constants.Biot.gestationAge, health >= Constants.Biot.spawnHealth {
			spawnChildren()
			lastSpawnedAge = age
		}

		frame += 1
	}
	
	func expire() {
		if let scene = OctopusKit.shared.currentScene as? WorldScene, let entity = self.entity, let node = entityNode {
			isExpired = true
			node.run(.group([.fadeOut(withDuration: 0.2), SKAction.scale(to: 0.1, duration: 0.2)])) {
				if scene.trackedEntity == entity {
					scene.stopTrackingEntity()
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
		
		if let rotation = entityNode?.zRotation {
			progressNode.zRotation = 2*π - rotation + π/2
		}
		
		guard frame.isMultiple(of: 2) else { return }
		
		let showingHealth = !healthNode.isHidden
		let showHealth = globalDataComponent?.showBiotHealth ?? false
		let showingHealthDetails = !healthDetailsNode.isHidden
		let showBiotHealthDetails = globalDataComponent?.showBiotHealthDetails ?? false
		let showingVision = !visionNode.isHidden

		if !showingHealth, showHealth{
			healthNode.alpha = 0
			healthNode.isHidden = false
			healthDetailsNode.alpha = !showingVision ? 0 : 1
			healthDetailsNode.isHidden = !showingVision || !showBiotHealthDetails
			healthNode.run(.fadeIn(withDuration: 0.2))
		}
		else if showingHealth, !showHealth {
			healthNode.run(.fadeOut(withDuration: 0.1)) {
				self.healthNode.isHidden = true
			}
		}
		
		if !showingHealthDetails, showBiotHealthDetails {
			healthDetailsNode.alpha = !showingVision ? 0 : 1
			healthDetailsNode.isHidden = !showingVision || !showBiotHealthDetails
		}
		else if showingVision, showingHealthDetails, !showBiotHealthDetails {
			healthDetailsNode.run(.fadeOut(withDuration: 0.1)) {
				self.healthDetailsNode.isHidden = true
			}
		}

		if showHealth {
			let overallHealthNode = healthMeterNodes[HealthMeter.overall.rawValue]
			var intenstity = health
			overallHealthNode.fillColor = SKColor(red: 1 - intenstity, green: intenstity, blue: 0, alpha: 1)
			
			if showingHealthDetails {
				
				progressNode.setProgress(progress)
				if let bodyColor = (entityNode as? SKShapeNode)?.fillColor {
					progressNode.progressRing.strokeColor = bodyColor.withAlpha(1)
				}
				
				let energyHealthNode = healthMeterNodes[HealthMeter.energy.rawValue]
				intenstity = foodEnergy/maximumEnergy
				energyHealthNode.fillColor = SKColor(red: 1 - intenstity, green: intenstity, blue: 0, alpha: 1)
				
				let hydrationHealthNode = healthMeterNodes[HealthMeter.hydration.rawValue]
				intenstity = hydration/Constants.Biot.maximumHydration
				hydrationHealthNode.fillColor = SKColor(red: 0, green: intenstity*0.75, blue: intenstity, alpha: 1)

				let staminaHealthNode = healthMeterNodes[HealthMeter.stamina.rawValue]
				intenstity = stamina * stamina
				staminaHealthNode.fillColor = SKColor(red: 1, green: intenstity, blue: intenstity, alpha: 1)
			}
		}
	}
		
	// display visual sensors
	func updateVisionNode() {
		guard frame.isMultiple(of: 2) else { return }
				
		let showingVision = !visionNode.isHidden
		let showingHealth = !healthNode.isHidden
		let showVision = globalDataComponent?.showBiotVision ?? false
		let showBiotHealthDetails = globalDataComponent?.showBiotHealth ?? false

		if !showingVision, showVision {
			eyeNodes.forEach({ eyeNode in
				eyeNode.run(.fadeOut(withDuration: 0.1), completion: {
					eyeNode.isHidden = true
				})
			})
			
			if showingHealth, showBiotHealthDetails {
				healthDetailsNode.alpha = 0
				healthDetailsNode.isHidden = false
				healthDetailsNode.run(.fadeIn(withDuration: 0.2))
			}
			
			visionNode.alpha = 0
			visionNode.isHidden = false
			visionNode.run(.fadeIn(withDuration: 0.2))
		}
		else if showingVision, !showVision {

			eyeNodes.forEach({ eyeNode in
				eyeNode.alpha = 0
				eyeNode.isHidden = false
				eyeNode.run(.fadeIn(withDuration: 0.1))
			})
			
			if showingHealth {
				healthDetailsNode.run(.fadeOut(withDuration: 0.1), completion: {
					self.healthDetailsNode.isHidden = true
				})
			}

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
						retinaNode.zPosition = Constants.ZeeOrder.biot + color.brightnessComponent
					}
					retinaNode.strokeColor = color
				}
			}
			
			if let onTopOfFoodAverage = brainComponent?.senses.onTopOfFood.average {
				let color = SKColor(red: 0, green: onTopOfFoodAverage.cgFloat, blue: 0, alpha: 1)
				onTopOfFoodNode.fillColor = color
			}
			
			if let onTopOfFWaterAverage = brainComponent?.senses.onTopOfWater.average {
				let color = SKColor(red: 0, green: onTopOfFWaterAverage.cgFloat * 0.75, blue: onTopOfFWaterAverage.cgFloat, alpha: 1)
				onTopOfWaterNode.fillColor = color
			}
		}
	}
	
	func updateThrusterNode() {
		
		guard frame.isMultiple(of: 2) else { return }
		
		let showingThrust = !thrusterNode.isHidden
		let showThrust = globalDataComponent?.showBiotThrust ?? false
		
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
			showRipples()
		}
	}
	
	func showStats() {
		
		if  let statsNode = coComponent(EntityStatsComponent.self)?.statsNode {
			
			if frame.isMultiple(of: 10) {
 				if globalDataComponent?.showBiotStats == true {
					
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
					let hydrationFormatted = (hydration/Constants.Biot.maximumHydration).formattedToPercentNoDecimal
					let staminaFormatted = stamina.formattedToPercentNoDecimal
					
					statsNode.setLineOfText("h: \(healthFormatted), e: \(energyFormatted), w: \(hydrationFormatted), s: \(staminaFormatted)", for: .line1)
					statsNode.setLineOfText("gen: \(genome.generation) | age: \((age/Constants.Biot.maximumAge).formattedToPercentNoDecimal) | mate: \(canMate ? "✓" : "✗") | preg: \(isPregnant ? "✓" : "✗") | prog: \(progress.formattedToPercent)", for: .line2)
					statsNode.setLineOfText("spawn: \(spawnCount), cf: \(cumulativeFoodEnergy.formattedNoDecimal), cw: \(cumulativeHydration.formattedNoDecimal), cd: \(cumulativeDamage.formatted)", for: .line3)
					statsNode.updateBackgroundNode()
				}
			}
			
			if let rotation = entityNode?.zRotation {
				statsNode.zRotation = 2*π - rotation
			}
		}
	}

	func spawnChildren(selfReplication: Bool = false) {
		guard let node = entityNode, let scene = OctopusKit.shared.currentScene, let matingGenome = matingGenome else {
			return
		}

		if let worldScene = scene as? WorldScene,
		   let worldComponent = worldScene.entity?.component(ofType: WorldComponent.self),
		   worldComponent.currentBiots.count >= Constants.Env.maximumBiots {
			// no more room in the dish, cache a single (potentailly) mutated clone and become nonpregnant
			let clonedGenome = Genome(parent: matingGenome)
			worldComponent.addUnbornGenome(clonedGenome)
			self.matingGenome = nil
			self.lastPregnantAge = 0
			node.run(SKAction.scale(to: 1, duration: 0.25))
			return
		}
		
		foodEnergy = foodEnergy / 4
		hydration = Constants.Biot.initialHydration
		incurStaminaChange(0.05)
		
		spawnCount += 1
		
		let selfReplicationSpawn = [(genome, -π/8), (genome, π/8)]
		let standardSpawn =  [(genome, -π/8), (matingGenome, π/8)]

		let spawn = selfReplication ? selfReplicationSpawn : standardSpawn
		
		for (parentGenome, angle) in spawn {
			
			let position = node.position - CGPoint(angle: node.zRotation + angle) * Constants.Biot.radius * 2
			let clonedGenome = Genome(parent: parentGenome)
			let childBiot = BiotComponent.createBiot(genome: clonedGenome, at: position, fountainComponent: RelayComponent(for: coComponent(ResourceFountainComponent.self)))
			childBiot.node?.zRotation = node.zRotation + angle + π
			
			if globalDataComponent?.showBiotStats ?? false {
				childBiot.addComponent(EntityStatsComponent())
			}
			if globalDataComponent?.showBiotEyeSpots ?? false {
				childBiot.addComponent(EyesComponent())
			}
			//print("\(currentColor)-🥚 id: \(clonedGenome.id), gen: \(clonedGenome.generation)")
			//print(clonedGenome.jsonString)
			
			scene.run(SKAction.wait(forDuration: 0.1)) {
				scene.addEntity(childBiot)
				
				if let hideNode = self.globalDataComponent?.hideSpriteNodes {
					childBiot.node?.isHidden = hideNode
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
		
		let overallHealthNode = healthMeterNodes[HealthMeter.overall.rawValue]
		
		if impact > 0 {
			let pulseUp = SKAction.scale(to: 1.25, duration: 0.2)
			let pulseDown = SKAction.scale(to: 1, duration: 0.4)
			let sequence = SKAction.sequence([pulseUp, .wait(forDuration: 0.1), pulseDown])
			sequence.timingMode = .easeInEaseOut
			overallHealthNode.run(sequence)
		}
		else {
			let pulseDown = SKAction.scale(to: 0.75, duration: 0.1)
			let pulseUp = SKAction.scale(to: 1, duration: 0.2)
			let sequence = SKAction.sequence([pulseDown, .wait(forDuration: 0.1), pulseUp])
			sequence.timingMode = .easeInEaseOut
			overallHealthNode.run(sequence)
		}
	}
}

extension BiotComponent {
		
	static func createBiot(genome: Genome, at position: CGPoint, fountainComponent: RelayComponent<ResourceFountainComponent>) -> OKEntity {

		let radius = Constants.Biot.radius
		let node = SKShapeNode(circleOfRadius: radius)
		node.name = Constants.NodeName.biot
		node.fillColor = SKColor.lightGray
		node.lineWidth = radius * 0.075
		node.strokeColor = .clear
		node.position = position
		node.zPosition = Constants.ZeeOrder.biot
		node.zRotation = CGFloat.randomAngle
		node.blendMode = Constants.Env.graphics.blendMode
		node.isAntialiased = Constants.Env.graphics.isAntialiased
		
		let biotComponent = BiotComponent(genome: genome)

		if Constants.Env.graphics.shadows {
			let shadowNode = SKShapeNode()
			shadowNode.path = node.path
			shadowNode.zPosition = Constants.ZeeOrder.biot - 6
			shadowNode.glowWidth = radius * 0.25
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
			eyeNode.lineWidth = Constants.Biot.radius * 0.1
			eyeNode.position = CGPoint(angle: angle) * radius * 0.65
			node.addChild(eyeNode)
			eyeNode.zPosition = node.zPosition + 0.2
			//eyeNode.isHidden = true
			eyeNodes.append(eyeNode)
		}
		
		let healthNode = SKNode()
		healthNode.isHidden = true
		healthNode.zPosition = Constants.ZeeOrder.biot + 0.1
		
		// health details
		let healthDetailsNode = SKNode()
		healthDetailsNode.isHidden = true
		healthDetailsNode.zPosition = Constants.ZeeOrder.biot + 0.1
		healthNode.addChild(healthDetailsNode)
				
		// main health meter
		var healthMeterNodes: [SKShapeNode] = []
		let healthMeterNode = SKShapeNode(circleOfRadius: radius * 0.25)
		healthMeterNode.zPosition = Constants.ZeeOrder.biot + 20
		healthMeterNode.fillColor = .darkGray
		healthMeterNode.lineWidth = radius * 0.02
		healthMeterNode.strokeColor = .black
		healthMeterNode.isAntialiased = Constants.Env.graphics.isAntialiased
		healthMeterNodes.append(healthMeterNode)
		healthNode.addChild(healthMeterNode)
		node.addChild(healthNode)

		// health detail meters
		for angle in [π/6, 0, -π/6] {
			let meterRadius: CGFloat = radius * 0.08
			let meterNode = SKShapeNode(circleOfRadius: meterRadius)
			meterNode.position = CGPoint(angle: angle) * radius * 0.55
			meterNode.fillColor = .black
			meterNode.strokeColor = .black
			meterNode.lineWidth = meterRadius * 0.2
			meterNode.blendMode = Constants.Env.graphics.blendMode
			healthDetailsNode.addChild(meterNode)
			healthMeterNodes.append(meterNode)
		}
		
		// progress
		let progressNode = ProgressNode(radius: radius * 0.28, lineWidth: Constants.Biot.radius * 0.1)
		healthDetailsNode.addChild(progressNode)
		progressNode.zPosition = Constants.ZeeOrder.biot + 0.09

		// speed boost
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
		speedNode.isAntialiased = Constants.Env.graphics.isAntialiased
		speedNode.zPosition = Constants.ZeeOrder.biot + 0.1
		node.addChild(speedNode)

		// armor
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
		armorNode.isAntialiased = Constants.Env.graphics.isAntialiased
		armorNode.zPosition = Constants.ZeeOrder.biot + 0.2
		node.addChild(armorNode)

		// vision
		let visionNode = SKNode()
		visionNode.isHidden = true
		visionNode.zPosition = Constants.ZeeOrder.biot + 0.2
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
		let resourceRadius: CGFloat = radius * 0.08
		let onTopOfFoodNode = SKShapeNode(circleOfRadius: resourceRadius)
		onTopOfFoodNode.position = CGPoint(angle: π - π/12) * radius * 0.55
		onTopOfFoodNode.fillColor = .black
		onTopOfFoodNode.strokeColor = .black
		onTopOfFoodNode.lineWidth = resourceRadius * 0.2
		onTopOfFoodNode.blendMode = Constants.Env.graphics.blendMode
		visionNode.addChild(onTopOfFoodNode)

		let onTopOfWaterNode = SKShapeNode(circleOfRadius: resourceRadius)
		onTopOfWaterNode.position = CGPoint(angle: π + π/12) * radius * 0.55
		onTopOfWaterNode.fillColor = .black
		onTopOfWaterNode.strokeColor = .black
		onTopOfWaterNode.lineWidth = resourceRadius * 0.2
		onTopOfWaterNode.blendMode = Constants.Env.graphics.blendMode
		visionNode.addChild(onTopOfWaterNode)

		// thrusters
		let thrusterNode = ThrusterNode(radius: radius)
		thrusterNode.isHidden = true
		biotComponent.thrusterNode = thrusterNode
		node.addChild(thrusterNode)

		// physics
		let physicsBody = SKPhysicsBody(circleOfRadius: radius * 1.15)
		physicsBody.categoryBitMask = Constants.CategoryBitMasks.biot
		physicsBody.collisionBitMask = Constants.CollisionBitMasks.biot
		physicsBody.contactTestBitMask = Constants.ContactBitMasks.biot
		physicsBody.allowsRotation = false
		physicsBody.usesPreciseCollisionDetection = true
		physicsBody.mass = 5
		
		physicsBody.linearDamping = 1
		physicsBody.friction = 1
		
		let range = SKRange(lowerLimit: 0, upperLimit: Constants.Env.worldRadius)
		let keepInBounds = SKConstraint.distance(range, to: .zero)
		node.constraints = [keepInBounds]

		// set the nodes in the component
		biotComponent.visionNode = visionNode
		biotComponent.retinaNodes = retinaNodes
		biotComponent.onTopOfFoodNode = onTopOfFoodNode
		biotComponent.onTopOfWaterNode = onTopOfWaterNode
		biotComponent.healthNode = healthNode
		biotComponent.healthDetailsNode = healthDetailsNode
		biotComponent.healthMeterNodes = healthMeterNodes
		biotComponent.progressNode = progressNode
		biotComponent.speedNode = speedNode
		biotComponent.armorNode = armorNode
		biotComponent.eyeNodes = eyeNodes

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
			biotComponent
		])
	}
}