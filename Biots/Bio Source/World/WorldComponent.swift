//
//  WorldComponent.swift
//  BioGenesis
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
	
	lazy var keyTrackerComponent = coComponent(KeyTrackerComponent.self)
	
	override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		PointerEventComponent.self,
		CameraComponent.self,
		KeyTrackerComponent.self,
		GlobalStatsComponent.self
	]}
	
	override func didAddToEntity(withNode node: SKNode) {
		guard let scene = OctopusKit.shared?.currentScene, let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideSpriteNodes else { return }
		
		if Constants.Env.graphics.showGrid {
			let blockSize = Constants.Env.gridBlockSize
			let gridSize = Int(Constants.Env.worldRadius / blockSize) * 2
			let gridNode = GridNode.create(blockSize: 400, rows: gridSize, cols: gridSize)
			gridNode.isHidden = hideNode
			scene.addChild(gridNode)
		}
		
		let worldRadius = Constants.Env.worldRadius
		let boundary = BoundaryComponent.createLoopWall(radius: worldRadius)
		boundary.node?.isHidden = hideNode
		scene.addEntity(boundary)
		
		let filename = Constants.Env.placementsFilename
		let placements: [NodePlacement] = loadJsonFromFile(filename)
		print("WorldComponent: loaded \(placements.count) placements from \(filename)")
				
		let targetAlgaeSupply = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.algaeTarget ?? 0
		let showFountainInfluence = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showAlgaeFountainInfluences ?? false

		// algae fountain(s)
		let alageFountain = ResourceFountainComponent.createFountain(position: .zero, minRadius: worldRadius * 0.2, maxRadius: worldRadius * 0.9, targetAlgaeSupply: targetAlgaeSupply.cgFloat)
		alageFountain.name = "mainFountain"

		if showFountainInfluence {
			alageFountain.addComponent(ResourceFountainInfluenceComponent())
		}
		scene.addEntity(alageFountain)
		
		for placement in placements {
			let position = CGPoint(angle: placement.angle.cgFloat) * placement.percentFromCenter.cgFloat * worldRadius
			let radius = placement.percentRadius.cgFloat * worldRadius
			
			if placement.placeableType == .zapper {
				let zapper = ZapperComponent.create(radius: radius, position: position)
				zapper.node?.isHidden = hideNode
				scene.addEntity(zapper)
			}
			else if placement.placeableType == .water {
				let water = WaterSourceComponent.create(radius: radius, position: position)
				alageFountain.component(ofType: ResourceFountainComponent.self)?.waterEntities.append(water)
				water.node?.isHidden = hideNode
				scene.addEntity(water)
			}
		}
 	}
	
	func addUnbornGenome(_ genome: Genome) {
		if unbornGenomes.count == Constants.Env.unbornGenomeCacheCount {
			unbornGenomes.remove(at: 0)
		}
		unbornGenomes.append(genome)
		print("added 1 unborn genome: \(genome.description), cache size: \(unbornGenomes.count)")
	}
		
	func addNewCell(genome: Genome, in scene: OKScene) -> OKEntity {
		
		let worldRadius = Constants.Env.worldRadius
		let distance = CGFloat.random(in: worldRadius * 0.35...worldRadius * 0.9)
		let position = CGPoint.randomDistance(distance)

		let fountainComponent = scene.entities.filter({ $0.component(ofType: ResourceFountainComponent.self) != nil }).first?.component(ofType: ResourceFountainComponent.self)
		let cell = CellComponent.createCell(genome: genome, at: position, fountainComponent: RelayComponent(for: fountainComponent))
		
		let showEyeSpots = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showCellEyeSpots ?? false
		if showEyeSpots {
			cell.addComponent(EyesComponent())
		}
		let showCellStats = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showCellStats ?? false
		if showCellStats {
			cell.addComponent(EntityStatsComponent())
		}
		scene.addEntity(cell)

		if let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideSpriteNodes {
			cell.node?.isHidden = hideNode
		}
		
		return cell
	}
				
	func displayStats() {
		
		guard let scene =  OctopusKit.shared?.currentScene else { return }
		let frame = scene.currentFrameNumber

		if frame.isMultiple(of: 50), let statsComponent = coComponent(GlobalStatsComponent.self) {
			
			let cellCount = scene.entities.filter({ $0.component(ofType: CellComponent.self) != nil }).count

			let cellStats = currentCellStats
			let statsText = "\(Int(frame).abbrev) | pop: \(cellCount)/\(Constants.Env.maximumCells), gen: \(cellStats.minGen)–\(cellStats.maxGen) | h: \(cellStats.avgHealth.formattedToPercent) | e: \(cellStats.avgEnergy.formattedToPercentNoDecimal) | w: \(cellStats.avgHydration.formattedToPercentNoDecimal) | s: \(cellStats.avgStamina.formattedToPercentNoDecimal) | mate: \(cellStats.canMateCount) | preg: \(cellStats.pregnantCount), spawned: \(cellStats.spawnAverage.formattedTo2Places) | alg: \(currentCellStats.resourceStats.algaeTarget.formattedNoDecimal)"

			statsComponent.updateStats(statsText)
			
			if frame > 0, frame.isMultiple(of: 20000) {
				print()
				print(statsText)
				print()
				(scene as? WorldScene)?.dumpGenomes()
			}
		}

	}
	
	override func update(deltaTime seconds: TimeInterval) {
		
		guard let scene =  OctopusKit.shared?.currentScene else { return }
		let frame = scene.currentFrameNumber
				
		// key event handling
		if let keyTracker = keyTrackerComponent {
			for keyCode in keyTracker.keyCodesDown {
				processWorldKeyDown(keyCode: keyCode, shiftDown: keyTracker.shiftDown, commandDown: keyTracker.commandDown)
			}
		}
		
		displayStats()
		
		// cell creation
		if frame >= Constants.Env.startupDelay && frame.isMultiple(of: Constants.Env.dispenseInterval), scene.entities.filter({ $0.component(ofType: CellComponent.self) != nil }).count < Constants.Env.minimumCells {
			
			if Constants.Env.randomRun {
				let genome = GenomeFactory.shared.newRandomGenome
				print("created random genome: \(genome.description)")
				let _ = addNewCell(genome: genome, in: scene)
			}
			else if unbornGenomes.count > 0 {
				if let highestGenGenome = unbornGenomes.sorted(by: { (genome1, genome2) -> Bool in
					genome1.generation > genome2.generation
				}).first {
					print("decanting unborn genome: \(highestGenGenome.description), cache size: \(unbornGenomes.count)")
					let _ = addNewCell(genome: highestGenGenome, in: scene)
					unbornGenomes = unbornGenomes.filter({ $0.id != highestGenGenome.id })
				}
			}
			else if GenomeFactory.shared.genomes.count > 0 {
				let genomeIndex = genomeDispenseIndex % GenomeFactory.shared.genomes.count
				var genome = GenomeFactory.shared.genomes[genomeIndex]
				genome.id = "\(genome.id)-\(genomeDispenseIndex)"
				print("dispensing genome from file: \(genome.id) - \(genomeIndex): \(genome.description)")
				let _ = addNewCell(genome: genome, in: scene)
				genomeDispenseIndex += 1
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
		static let zero = ResourceStats(algaeTarget: 0, algaeSupply: 0)
	}
	
	struct CellStats {
		var minGen: Int
		var maxGen: Int
		var avgEnergy: CGFloat
		var avgHydration: CGFloat
		var avgStamina: CGFloat
		var avgHealth: CGFloat
		
		var canMateCount: Int
		var pregnantCount: Int
		var spawnAverage: CGFloat
		
		var resourceStats: ResourceStats

		static var zero: CellStats {
			return CellStats(minGen: 0, maxGen: 0, avgEnergy: 0, avgHydration: 0, avgStamina: 0, avgHealth: 0, canMateCount: 0, pregnantCount: 0, spawnAverage: 0, resourceStats: .zero)
		}
	}
	
	
	var currentCells: [CellComponent] {
		return OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: CellComponent.self) }) ?? []
	}
	
	var currentCellStats: CellStats {
				
		let cells = currentCells
		
		let minGen = cells.map({$0.genome.generation}).min() ?? 0
		let maxGen = cells.map({$0.genome.generation}).max() ?? 0

		let averageEnergy = cells.count == 0 ? 0 : cells.reduce(0) { $0 + $1.foodEnergy/$1.maximumEnergy } / cells.count.cgFloat
		let averageHydration = cells.count == 0 ? 0 : cells.reduce(0) { $0 + $1.hydration/Constants.Cell.maximumHydration } / cells.count.cgFloat
		let averageStamina = cells.count == 0 ? 0 : cells.reduce(0) { $0 + $1.stamina } / cells.count.cgFloat
		let averageHealth = cells.count == 0 ? 0 : cells.reduce(0) { $0 + $1.health } / cells.count.cgFloat

		let canMateCount = cells.reduce(0) { $0 + ($1.canMate ? 1 : 0) }
		let pregnantCount = cells.reduce(0) { $0 + ($1.isPregnant ? 1 : 0) }
		let spawnAverage = cells.count == 0 ? 0 : CGFloat(cells.reduce(0) { $0 + $1.spawnCount }) / cells.count.cgFloat

		return CellStats(minGen: minGen, maxGen: maxGen, avgEnergy: averageEnergy, avgHydration: averageHydration, avgStamina: averageStamina, avgHealth: averageHealth, canMateCount: canMateCount, pregnantCount: pregnantCount, spawnAverage: spawnAverage, resourceStats: currentResourceStats)
	}

	var currentResourceStats: ResourceStats {
		let fountains: [ResourceFountainComponent] = OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: ResourceFountainComponent.self) }) ?? []
		
		let algaeTarget = fountains.reduce(0) { $0 + $1.targetAlgaeSupply }
		let algaeSupply = fountains.reduce(0) { $0 + $1.currentAlgaeSupply }
		
		return ResourceStats(algaeTarget: algaeTarget, algaeSupply: algaeSupply)
	}
	
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
			if let scene = OctopusKit.shared.currentScene, let globalDataComponent = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) {
				globalDataComponent.cameraZoom = Double(cameraZoom)
			}
			let zoomAction = SKAction.scale(to: cameraZoom, duration: Constants.Camera.animationDuration)
			//let moveAction = SKAction.move(to: .zero, duration: Constants.Camera.animationDuration)
			camera.run(zoomAction)
			//camera.run(.group([zoomAction, moveAction]))
			break

		case Keycode.equals, // camera zoom
			 Keycode.minus:
			let scaleFactor: CGFloat = keyCode == Keycode.minus ? Constants.Camera.scaleFactor : 1/Constants.Camera.scaleFactor
			
			cameraZoom = camera.xScale * scaleFactor
			cameraZoom = cameraZoom.clamp(Constants.Camera.zoomMin, Constants.Camera.zoomMax)
			if let scene = OctopusKit.shared.currentScene, let globalDataComponent = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) {
				globalDataComponent.cameraZoom = Double(cameraZoom)
			}
			let zoomAction = SKAction.scale(to: cameraZoom, duration: Constants.Camera.animationDuration)
			camera.run(zoomAction)
			break
			
		case Keycode.leftArrow, // camera pan
			 Keycode.rightArrow,
			 Keycode.downArrow,
			 Keycode.upArrow:
			
			if let cameraComponent = entity?.component(ofType: CameraComponent.self) {
				(OctopusKit.shared.currentScene as? WorldScene)?.trackedEntity = nil
				cameraComponent.nodeToTrack = nil
			}

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
}
