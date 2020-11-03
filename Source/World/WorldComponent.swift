//
//  WorldComponent.swift
//  Biots
//
//  Created by Robert Silverman on 4/11/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import SpriteKit
import GameplayKit
import OctopusKit

final class WorldComponent: OKComponent, OKUpdatableComponent {

	var cameraZoom: CGFloat = Constants.Camera.initialScale
	var genomeDispenseIndex = 0
	var unbornGenomes: [Genome] = []
	var currentFrame = 0
	
	lazy var keyTrackerComponent = coComponent(KeyTrackerComponent.self)
	
	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		PointerEventComponent.self,
		CameraComponent.self,
		KeyTrackerComponent.self,
		GlobalStatsComponent.self
	]}
	
	// MARK: Create

	override func didAddToEntity(withNode node: SKNode) {
		createWorld()
 	}
	
	func createWorld() {
		
		guard let scene = OctopusKit.shared?.currentScene else { return }
		
		coComponent(GlobalStatsComponent.self)?.updateStats("Starting Up...")
		
		cameraZoom = Constants.Camera.initialScale
		if let camera = coComponent(CameraComponent.self)?.camera {
			camera.position = .zero
			camera.xScale = cameraZoom
			camera.yScale = cameraZoom
		}
		
		// cleanup and prepare
		removeAllEntities()
		unbornGenomes.removeAll()
		currentFrame = 0
		let gameConfig = GameManager.shared.gameConfig
		let worldRadius = GameManager.shared.gameConfig.worldRadius

		// grid
		if Constants.Env.graphics.showGrid {
			let blockSize = Constants.Env.gridBlockSize
			let gridSize = Int(GameManager.shared.gameConfig.worldRadius / blockSize) * 2
			let gridNode = GridNode.create(blockSize: 400, rows: gridSize, cols: gridSize)
			scene.addChild(gridNode)
		}
		
		// boundary wall
		let boundary = BoundaryComponent.createLoopWall(radius: worldRadius)
		scene.addEntity(boundary)
						
		// world objects
		let worldObjects = gameConfig.worldObjects
		for worldObject in worldObjects {
			let position = CGPoint(angle: worldObject.angle.cgFloat) * worldObject.percentFromCenter.cgFloat * worldRadius
			let radius = worldObject.percentRadius.cgFloat * worldRadius
			
			if worldObject.placeableType == .zapper {
				let zapper = ZapperComponent.create(radius: radius, position: position)
				scene.addEntity(zapper)
			}
			else if worldObject.placeableType == .water || worldObject.placeableType == .mud {
				let water = WaterSourceComponent.create(radius: radius, position: position, isMud: worldObject.placeableType == .mud)
				scene.addEntity(water)
			}
		}
		
		// algae fountain(s)
		let targetAlgaeSupply = gameConfig.algaeTarget
		scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.algaeTarget = targetAlgaeSupply
		let alageFountain = ResourceFountainComponent.create(position: .zero, minRadius: worldRadius * 0.2, maxRadius: worldRadius * 0.9, targetAlgaeSupply: targetAlgaeSupply.cgFloat)
		scene.addEntity(alageFountain)
	}
	
	func removeAllEntities() {
		
		guard let scene = OctopusKit.shared?.currentScene else { return }

		scene.entities(withName: Constants.NodeName.algae)?.forEach({ entity in
			scene.removeEntity(entity)
		})
		
		scene.entities(withName: Constants.NodeName.biot)?.forEach({ entity in
			scene.removeEntity(entity)
		})
		
		scene.entities(withName: Constants.NodeName.wall)?.forEach({ entity in
			scene.removeEntity(entity)
		})
		
		scene.entities(withName: Constants.NodeName.zapper)?.forEach({ entity in
			scene.removeEntity(entity)
		})

		scene.entities(withName: Constants.NodeName.water)?.forEach({ entity in
			scene.removeEntity(entity)
		})
				
		scene.entities(withName: Constants.NodeName.algaeFountain)?.forEach({ entity in
			scene.removeEntity(entity)
		})
		
		if let gridNode = scene.childNode(withName: Constants.NodeName.grid) {
			gridNode.removeFromParent()
		}
	}
	
	// MARK: Update
	
	override func update(deltaTime seconds: TimeInterval) {
		
		guard let scene =  OctopusKit.shared?.currentScene else { return }
				
		let gameConfig = GameManager.shared.gameConfig
		// key event handling
		if let keyTracker = keyTrackerComponent {
			for keyCode in keyTracker.keyCodesDown {
				processWorldKeyDown(keyCode: keyCode, shiftDown: keyTracker.shiftDown, commandDown: keyTracker.commandDown)
			}
		}
		
		displayStats()
		
		// biot creation
		if currentFrame >= gameConfig.gameMode.dispenseDelay && currentFrame.isMultiple(of: gameConfig.gameMode.dispenseInterval), scene.entities.filter({ $0.component(ofType: BiotComponent.self) != nil }).count < gameConfig.minimumBiotCount {
			
			if unbornGenomes.count > 0 {
				if let highestGenGenome = unbornGenomes.sorted(by: { (genome1, genome2) -> Bool in
					genome1.generation > genome2.generation
				}).first {
					OctopusKit.logForSimInfo.add("decanting unborn genome: \(highestGenGenome.description), cache size: \(unbornGenomes.count)")
					let _ = addNewBiot(genome: highestGenGenome, in: scene)
					unbornGenomes = unbornGenomes.filter({ $0.id != highestGenGenome.id })
				}
			}
			else if gameConfig.gameMode == .random {
				let genome = Genome.newRandomGenome
				OctopusKit.logForSimInfo.add("created random genome: \(genome.description)")
				let _ = addNewBiot(genome: genome, in: scene)
			}
			else if GameManager.shared.gameConfig.genomes.count > 0 {
				let genomes = GameManager.shared.gameConfig.genomes
				let genomeIndex = genomeDispenseIndex % genomes.count
				var genome = genomes[genomeIndex]
				genome.id = "\(genome.id)-\(genomeDispenseIndex)"
				OctopusKit.logForSimInfo.add("dispensing genome from file: \(genome.id) - \(genomeIndex): \(genome.description)")
				let _ = addNewBiot(genome: genome, in: scene)
				genomeDispenseIndex += 1
			}
		}
		
		currentFrame += 1
	}

	// MARK: Biots
	
	func addUnbornGenome(_ genome: Genome) {
		if unbornGenomes.count == Constants.Env.unbornGenomeCacheCount {
			unbornGenomes.remove(at: 0)
		}
		unbornGenomes.append(genome)
		OctopusKit.logForSimInfo.add("added 1 unborn genome: \(genome.description), cache size: \(unbornGenomes.count)")
	}
		
	func addNewBiot(genome: Genome, in scene: OKScene) -> OKEntity {
		
		let worldRadius = GameManager.shared.gameConfig.worldRadius
		let distance = CGFloat.random(in: worldRadius * 0.35...worldRadius * 0.9)
		let position = CGPoint.randomDistance(distance)

		let fountainComponent = scene.entities.filter({ $0.component(ofType: ResourceFountainComponent.self) != nil }).first?.component(ofType: ResourceFountainComponent.self)
		let biot = BiotComponent.createBiot(genome: genome, at: position, fountainComponent: RelayComponent(for: fountainComponent))
		
		let showEyeSpots = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showBiotEyeSpots ?? false
		if showEyeSpots {
			biot.addComponent(EyesComponent())
		}
		let showBiotStats = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showBiotStats ?? false
		if showBiotStats {
			biot.addComponent(EntityStatsComponent())
		}
		scene.addEntity(biot)

		if let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideSpriteNodes {
			biot.node?.isHidden = hideNode
		}
		
		return biot
	}
				
	// MARK: Stats
	
	func displayStats() {
		
		guard let scene = OctopusKit.shared?.currentScene else { return }
		
		let gameConfig = GameManager.shared.gameConfig
		let dispenseDelay = gameConfig.gameMode.dispenseDelay
		let frame = currentFrame - dispenseDelay

		if currentFrame >= 50, frame.isMultiple(of: 50), let statsComponent = coComponent(GlobalStatsComponent.self) {
			
			let biotCount = scene.entities.filter({ $0.component(ofType: BiotComponent.self) != nil }).count

			let mode = gameConfig.gameMode != .normal ? " (\(gameConfig.gameMode.humanReadableDescription))" : ""
			let name = gameConfig.name
			let biotStats = currentBiotStats
			
			let labelAttrs = Constants.Stats.labelAttrs
			let valueAttrs = Constants.Stats.valueAttrs
			let iconAttrs = Constants.Stats.iconAttrs

			let builder = AttributedStringBuilder()
			builder.defaultAttributes = valueAttrs + [.alignment(.center)]
			builder
				.text("FILE   ", attributes: labelAttrs)
				.text("\(name)\(mode)")
				.text("      🕒 ", attributes: iconAttrs)
				.text("\(Int(frame).abbrev)")
				.text("      📶 ", attributes: iconAttrs)
				.text("\(biotCount)/\(gameConfig.maximumBiotCount)")
				.text("      🥚 ", attributes: iconAttrs)
				.text("\(unbornGenomes.count)")
				.text("      ↗️ ", attributes: iconAttrs)
				.text("\(biotStats.minGen.formatted)–\(biotStats.maxGen.formatted)")
				.text("      🌡️ ", attributes: iconAttrs)
				.text("\(biotStats.avgHealth.formattedToPercentNoDecimal)")
				.text("      ⚡ ", attributes: iconAttrs)
				.text("\(biotStats.avgEnergy.formattedToPercentNoDecimal)")
				.text("      💧 ", attributes: iconAttrs)
				.text("\(biotStats.avgHydration.formattedToPercentNoDecimal)")
				.text("      💪🏻 ", attributes: iconAttrs)
				.text("\(biotStats.avgStamina.formattedToPercentNoDecimal)")
				.text("      🤰🏻 ", attributes: iconAttrs)
				.text("\(biotStats.pregnantPercent.formattedToPercentNoDecimal)")
				.text("      👶🏻 ", attributes: iconAttrs)
				.text("\(biotStats.spawnAverage.formattedToPercentNoDecimal)")
				.text("      🌱 ", attributes: iconAttrs)
				.text("\(Int(currentBiotStats.resourceStats.algaeTarget).abbrev)")

			statsComponent.updateStats(builder.attributedString)
			
//			if frame > 0, frame.isMultiple(of: 20000) {
//				print()
//				print(statsText)
//				print()
//				(scene as? WorldScene)?.dumpGenomes()
//			}
		}
	}
	
	/*
	var currentRunningTime: String {
		let hours = Int(totalTime*2) / 3600
		let minutes = Int(totalTime*2) / 60 % 60
		let seconds = Int(totalTime*2) % 60
		return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
	}
	*/
	
	struct ResourceStats {
		var algaeTarget: CGFloat
		var algaeSupply: CGFloat
		var algaeCount: Int
		static let zero = ResourceStats(algaeTarget: 0, algaeSupply: 0, algaeCount: 0)
	}
	
	struct BiotStats {
		var minGen: Int
		var maxGen: Int
		var avgEnergy: CGFloat
		var avgHydration: CGFloat
		var avgStamina: CGFloat
		var avgHealth: CGFloat
		
		var pregnantPercent: CGFloat
		var spawnAverage: CGFloat
		
		var resourceStats: ResourceStats

		static var zero: BiotStats {
			return BiotStats(minGen: 0, maxGen: 0, avgEnergy: 0, avgHydration: 0, avgStamina: 0, avgHealth: 0, pregnantPercent: 0, spawnAverage: 0, resourceStats: .zero)
		}
	}
	
	var currentBiots: [BiotComponent] {
		return OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: BiotComponent.self) }) ?? []
	}
	
	var currentBiotStats: BiotStats {
				
		let biots = currentBiots
		
		let minGen = biots.map({$0.genome.generation}).min() ?? 0
		let maxGen = biots.map({$0.genome.generation}).max() ?? 0

		let averageEnergy = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.foodEnergy/$1.maximumEnergy } / biots.count.cgFloat
		let averageHydration = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.hydration/$1.maximumHydration } / biots.count.cgFloat
		let averageStamina = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.stamina } / biots.count.cgFloat
		let averageHealth = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.health } / biots.count.cgFloat

		let pregnantPercent = biots.count == 0 ? 0 : CGFloat(biots.reduce(0) { $0 + ($1.isPregnant ? 1 : 0) }) / biots.count.cgFloat
		let spawnAverage = biots.count == 0 ? 0 : CGFloat(biots.reduce(0) { $0 + $1.spawnCount }) / biots.count.cgFloat

		return BiotStats(minGen: minGen, maxGen: maxGen, avgEnergy: averageEnergy, avgHydration: averageHydration, avgStamina: averageStamina, avgHealth: averageHealth, pregnantPercent: pregnantPercent, spawnAverage: spawnAverage, resourceStats: currentResourceStats)
	}

	var currentResourceStats: ResourceStats {
		let fountains: [ResourceFountainComponent] = OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: ResourceFountainComponent.self) }) ?? []
		
		let algaeTarget = fountains.reduce(0) { $0 + $1.targetAlgaeSupply }
		let algaeSupply = fountains.reduce(0) { $0 + $1.currentAlgaeSupply }
		let algaeCount = fountains.reduce(0) { $0 + $1.algaeEntities.count }
		
		return ResourceStats(algaeTarget: algaeTarget, algaeSupply: algaeSupply, algaeCount: algaeCount)
	}
	
	// MARK: interaction
	
	func zoomAndCenter(scale: CGFloat = 25) {
		guard let camera = coComponent(CameraComponent.self)?.camera else { return }
		
		cameraZoom = scale
		let zoomAction = SKAction.scale(to: cameraZoom, duration: Constants.Camera.animationDuration)
		let moveAction = SKAction.move(to: .zero, duration: Constants.Camera.animationDuration)
		let sequence = SKAction.group([zoomAction, moveAction])
		camera.run(sequence)
	}
	
	func processWorldKeyDown(keyCode: UInt16, shiftDown: Bool, commandDown: Bool) {
				
		guard let camera = coComponent(CameraComponent.self)?.camera else { return }

		switch keyCode {
			
		case Keycode.z:
			cameraZoom = shiftDown ? 10 : Constants.Camera.initialScale
			let zoomAction = SKAction.scale(to: cameraZoom, duration: Constants.Camera.animationDuration)
			let moveAction = SKAction.move(to: .zero, duration: Constants.Camera.animationDuration)
			camera.run(.group([zoomAction, moveAction]))
			checkLevelOfDetail()
			break

		case Keycode.equals, // camera zoom
			 Keycode.minus:
			let scaleFactor: CGFloat = keyCode == Keycode.minus ? Constants.Camera.scaleFactor : 1/Constants.Camera.scaleFactor
			
			cameraZoom = camera.xScale * scaleFactor
			cameraZoom = cameraZoom.clamp(Constants.Camera.zoomMin, Constants.Camera.zoomMax)
			let zoomAction = SKAction.scale(to: cameraZoom, duration: Constants.Camera.animationDuration)
			camera.run(zoomAction)
			checkLevelOfDetail()
			break
			
		case Keycode.leftArrow, // camera pan
			 Keycode.rightArrow,
			 Keycode.downArrow,
			 Keycode.upArrow:
			
			(OctopusKit.shared.currentScene as? WorldScene)?.stopTrackingEntity()

			var vector: CGVector = .zero
			let boost = Constants.Camera.panBoost
			
			vector.dx += keyCode == Keycode.leftArrow ? -boost : 0
			vector.dx += keyCode == Keycode.rightArrow ? boost : 0
			vector.dy += keyCode == Keycode.downArrow ? -boost : 0
			vector.dy += keyCode == Keycode.upArrow ? boost : 0

			let moveAction = SKAction.move(by:vector, duration: Constants.Camera.animationDuration)
			camera.run(moveAction)
			break

		default: break
		
		}
	}
	
	func checkLevelOfDetail() {
		guard let globalDataComponent = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) else {
			return
		}
		//print(cameraZoom.formattedTo2Places)
		if cameraZoom >= Constants.Camera.levelOfDetailMedium {
			globalDataComponent.showBiotVision = false
			globalDataComponent.showBiotThrust = false
		}
		if cameraZoom >= Constants.Camera.levelOfDetailLow {
			globalDataComponent.showBiotHealth = false
		}
	}
}
