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
	var currentFrame = 0
	
	var generalDispensary: GenomeDispensary?
	var omnivoreDispensary: GenomeDispensary?
	var herbivoreDispensary: GenomeDispensary?
	
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
		coComponent(GlobalStatsComponent.self)?.setSimpleText(text: "🚀 Starting up...")
		
		cameraZoom = Constants.Camera.initialScale
		if let camera = coComponent(CameraComponent.self)?.camera {
			camera.position = .zero
			camera.xScale = cameraZoom
			camera.yScale = cameraZoom
		}
		
		// cleanup and prepare
		removeAllEntities()
		currentFrame = 0
				
		let gameConfig = GameManager.shared.gameConfig
		let worldRadius = GameManager.shared.gameConfig.worldRadius
		
		if gameConfig.simulationMode == .predatorPrey || gameConfig.simulationMode == .randomPredatorPrey {
			omnivoreDispensary = GenomeDispensary(dispensaryType: .omnivore, gameConfig: gameConfig)
			herbivoreDispensary = GenomeDispensary(dispensaryType: .herbivore, gameConfig: gameConfig)
		} else {
			generalDispensary = GenomeDispensary(dispensaryType: .general, gameConfig: gameConfig)
		}
		
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
				let zapper = ZapperComponent.create(radius: radius, position: position, isBrick: false)
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
		let alageFountain = ResourceFountainComponent.create(position: .zero, minRadius: worldRadius * 0.15, maxRadius: worldRadius * 0.9, targetAlgaeSupply: targetAlgaeSupply.cgFloat)
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
		let gameConfig = GameManager.shared.gameConfig
		
		// key event handling
		if let keyTracker = keyTrackerComponent {
			for keyCode in keyTracker.keyCodesDown {
				processWorldKeyDown(keyCode: keyCode, shiftDown: keyTracker.shiftDown, commandDown: keyTracker.commandDown)
			}
		}
		
		displayStats()
				
		// biot creation
		if currentFrame >= gameConfig.simulationMode.dispenseDelay && currentFrame.isMultiple(of: gameConfig.simulationMode.dispenseInterval) {
			topOffGenomes(gameConfig: gameConfig)
		}
		
		currentFrame += 1
	}
	
	// MARK: Genome Dispening

	func shouldCacheGenome(species: Species) -> Bool {
		let simulationMode = GameManager.shared.gameConfig.simulationMode

		switch simulationMode {
			
			case .predatorPrey, .randomPredatorPrey:
			return species == .omnivore ?
				omnivoreDispensary?.shouldCacheGenome(currentCount: currentOmnivores.count) ?? false :
				herbivoreDispensary?.shouldCacheGenome(currentCount: currentHerbivores.count) ?? false
				
			default: return generalDispensary?.shouldCacheGenome(currentCount: currentBiots.count) ?? false
		}
	}
	
	func mostFitGenomeFromCache(species: Species) -> Genome? {
		let simulationMode = GameManager.shared.gameConfig.simulationMode

		switch simulationMode {
			case .predatorPrey, .randomPredatorPrey:
			return species == .omnivore ? omnivoreDispensary?.mostFitGenome(removeFromCache: true) : herbivoreDispensary?.mostFitGenome(removeFromCache: true)
			default: return generalDispensary?.mostFitGenome(removeFromCache: true)
		}
	}
		
	func topOffGenomes(gameConfig: GameConfig) {
				
		guard let scene = OctopusKit.shared?.currentScene else { return }

		if gameConfig.simulationMode == .predatorPrey || gameConfig.simulationMode == .randomPredatorPrey {
			if let genome = herbivoreDispensary?.nextGenome(currentCount: currentHerbivores.count) {
				//OctopusKit.logForSimInfo.add("created herbivore genome: \(genome.description)")
				let _ = addNewBiot(genome: genome, in: scene)
			}
			else if let genome = omnivoreDispensary?.nextGenome(currentCount: currentOmnivores.count) {
				//OctopusKit.logForSimInfo.add("created omnivore genome: \(genome.description)")
				let _ = addNewBiot(genome: genome, in: scene)
			}
		}
		else if let genome = generalDispensary?.nextGenome(currentCount: currentBiots.count) {
			//OctopusKit.logForSimInfo.add("created general genome: \(genome.description)")
			let _ = addNewBiot(genome: genome, in: scene)
		}
	}
	
	func cacheGenome(_ genome: Genome, averageHealth: Float) {
		let simulationMode = GameManager.shared.gameConfig.simulationMode
		
		if simulationMode == .predatorPrey || simulationMode == .randomPredatorPrey {
			if genome.isOmnivore {
				omnivoreDispensary?.cacheGenome(genome, averageHealth: averageHealth)
			}
			else {
				herbivoreDispensary?.cacheGenome(genome, averageHealth: averageHealth)
			}
		} else {
			generalDispensary?.cacheGenome(genome, averageHealth: averageHealth)
		}
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
		
		guard let scene = OctopusKit.shared?.currentScene as? WorldScene else { return }
		
		let gameConfig = GameManager.shared.gameConfig
		let dispenseDelay = gameConfig.simulationMode.dispenseDelay
		let frame = currentFrame - dispenseDelay

		if currentFrame >= 50, frame.isMultiple(of: 50), let statsComponent = coComponent(GlobalStatsComponent.self) {
			
			let biotCount = scene.entities.filter({ $0.component(ofType: BiotComponent.self) != nil }).count

			let biotStats = currentBiotStats
			
			let labelAttrs = Constants.Stats.labelAttrs
			let valueAttrs = Constants.Stats.valueAttrs
			let iconAttrs = Constants.Stats.iconAttrs
			
			let labelSmalllAttrs = Constants.Stats.labelSmallAttrs
			let valueSmallAttrs = Constants.Stats.valueSmallAttrs
			let iconSmallAttrs = Constants.Stats.iconSmallAttrs

			let builder = AttributedStringBuilder()
			builder.defaultAttributes = valueAttrs + [.alignment(.center)]
			
			if gameConfig.simulationMode != .normal {
				builder.text("MODE   ", attributes: labelAttrs).text("\(gameConfig.simulationMode.humanReadableDescription)")
			}
			
			builder
				.text("      🕒 ", attributes: iconAttrs)
				.text("\(Int(frame).abbrev)")
				.text("      🌱 ", attributes: iconAttrs)
				.text("\(Int(currentBiotStats.resourceStats.algaeTarget).abbrev)")

				.text("      📶 ", attributes: iconAttrs)
				.text("\(biotCount)/\(gameConfig.maximumBiotCount)")
				
			if gameConfig.simulationMode == .predatorPrey || gameConfig.simulationMode == .randomPredatorPrey {
				builder
					.text("      🐰 ", attributes: iconAttrs)
					.text("\(currentHerbivores.count)")
					.text(" +🥚 ", attributes: iconAttrs)
					.text("\(herbivoreDispensary?.genomeCache.count ?? 0)")
					.text("      🦊 ", attributes: iconAttrs)
					.text("\(currentOmnivores.count)")
					.text(" +🥚 ", attributes: iconAttrs)
					.text("\(omnivoreDispensary?.genomeCache.count ?? 0)")
			} else {
				builder
					.text("      🥚 ", attributes: iconAttrs)
					.text("\(generalDispensary?.genomeCache.count ?? 0)")
			}
				
			if gameConfig.simulationMode == .predatorPrey || gameConfig.simulationMode == .randomPredatorPrey {
				builder
					.text("      ↗️🐰 ", attributes: iconAttrs)
					.text("\(biotStats.minGenHerbivore.formatted)–\(biotStats.maxGenHerbivore.formatted)")
					.text("      ↗️🦊 ", attributes: iconAttrs)
					.text("\(biotStats.minGenOmnivore.formatted)–\(biotStats.maxGenOmnivore.formatted)")
			}
			else {
				builder
					.text("      ↗️ ", attributes: iconAttrs)
					.text("\(biotStats.minGen.formatted)–\(biotStats.maxGen.formatted)")
			}
			
			builder
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
				.newline()
				.newline()

				.text("FILE   ", attributes: labelSmalllAttrs)
				.text("\(gameConfig.name)", attributes: valueSmallAttrs)
				.text("      🥚 ", attributes: iconSmallAttrs)
				.text("\(gameConfig.genomes.count)", attributes: valueSmallAttrs)
				.text("      ↗️ ", attributes: iconSmallAttrs)
				.text("\(gameConfig.minGeneration.formatted)–\(gameConfig.maxGeneration.formatted)", attributes: valueSmallAttrs)
				.text("      🌎 ", attributes: iconSmallAttrs)
				.text("\(gameConfig.worldBlockCount)", attributes: valueSmallAttrs)
				
			if gameConfig.useCrossover {
				builder
					.text("      🤞🏻", attributes: iconSmallAttrs)
			}
				
			statsComponent.updateStats(builder.attributedString)
			
			if frame > 0, frame.isMultiple(of: 20000), let globalDataComponent = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) {
				let gameConfig = GameManager.shared.gameConfig
				let sortedGenomes: [Genome] = scene.currentGenomes.sorted { (genome1, genome2) -> Bool in
					return genome1.species.rawValue > genome2.species.rawValue
				}
				let saveState = SaveState(name: "\(gameConfig.name)", simulationMode: gameConfig.simulationMode, algaeTarget: globalDataComponent.algaeTarget, worldBlockCount: gameConfig.worldBlockCount, worldObjects: scene.currentWorldObjects, genomes: sortedGenomes, minimumBiotCount: gameConfig.minimumBiotCount, maximumBiotCount: gameConfig.maximumBiotCount, omnivoreToHerbivoreRatio: Double(gameConfig.omnivoreToHerbivoreRatio), useCrossover: gameConfig.useCrossover)

				LocalFileManager.shared.saveStateToFile(saveState, filename: "\(Constants.Env.filenameSaveStateSave).backup")
			}
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
		var minGenHerbivore: Int
		var maxGenHerbivore: Int
		var minGenOmnivore: Int
		var maxGenOmnivore: Int

		var avgEnergy: CGFloat
		var avgHydration: CGFloat
		var avgStamina: CGFloat
		var avgHealth: CGFloat
		
		var pregnantPercent: CGFloat
		var spawnAverage: CGFloat
		
		var resourceStats: ResourceStats

		static var zero: BiotStats {
			return BiotStats(minGen: 0, maxGen: 0, minGenHerbivore: 0, maxGenHerbivore: 0, minGenOmnivore: 0, maxGenOmnivore: 0, avgEnergy: 0, avgHydration: 0, avgStamina: 0, avgHealth: 0, pregnantPercent: 0, spawnAverage: 0, resourceStats: .zero)
		}
	}
	
	var currentBiots: [BiotComponent] {
		return OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: BiotComponent.self) }) ?? []
	}
	
	var currentOmnivores: [BiotComponent] {
		return currentBiots.filter({ $0.genome.isOmnivore })
	}
	
	var currentHerbivores: [BiotComponent] {
		return currentBiots.filter({ $0.genome.isHerbivore })
	}
	
	var currentBiotStats: BiotStats {
				
		let biots = currentBiots
		let minGen = biots.map({$0.genome.generation}).min() ?? 0
		let maxGen = biots.map({$0.genome.generation}).max() ?? 0

		let herbivores = currentHerbivores
		let minGenHerbivore = herbivores.map({$0.genome.generation}).min() ?? 0
		let maxGenHerbivore = herbivores.map({$0.genome.generation}).max() ?? 0

		let omnivores = currentOmnivores
		let minGenOmnivore = omnivores.map({$0.genome.generation}).min() ?? 0
		let maxGenOmnivore = omnivores.map({$0.genome.generation}).max() ?? 0

		let averageEnergy = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.foodEnergy/$1.maximumEnergy } / biots.count.cgFloat
		let averageHydration = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.hydration/$1.maximumHydration } / biots.count.cgFloat
		let averageStamina = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.stamina } / biots.count.cgFloat
		let averageHealth = biots.count == 0 ? 0 : biots.reduce(0) { $0 + $1.healthRunningValue.averageOfMostRecent(memory: 10).cgFloat } / biots.count.cgFloat

		let pregnantPercent = biots.count == 0 ? 0 : CGFloat(biots.reduce(0) { $0 + ($1.isPregnant ? 1 : 0) }) / biots.count.cgFloat
		let spawnAverage = biots.count == 0 ? 0 : CGFloat(biots.reduce(0) { $0 + $1.spawnCount }) / biots.count.cgFloat

		return BiotStats(minGen: minGen, maxGen: maxGen,  minGenHerbivore: minGenHerbivore, maxGenHerbivore: maxGenHerbivore, minGenOmnivore: minGenOmnivore, maxGenOmnivore: maxGenOmnivore, avgEnergy: averageEnergy, avgHydration: averageHydration, avgStamina: averageStamina, avgHealth: averageHealth, pregnantPercent: pregnantPercent, spawnAverage: spawnAverage, resourceStats: currentResourceStats)
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
