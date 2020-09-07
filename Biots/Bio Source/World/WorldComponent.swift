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
	var allGenomesFromFileDispensed = false

    override var requiredComponents: [GKComponent.Type]? {[
		SpriteKitComponent.self,
		PointerEventComponent.self,
		CameraComponent.self,
		KeyTrackerComponent.self,
		GlobalStatsComponent.self
	]}
	
	override func didAddToEntity(withNode node: SKNode) {
		guard let scene = OctopusKit.shared?.currentScene, let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideAlgae else { return }
		
		let blockSize = Constants.Env.gridBlockSize
		let gridSize = Int(Constants.Env.worldRadius / blockSize) * 2
		let gridNode = GridNode.create(blockSize: 400, rows: gridSize, cols: gridSize)
		gridNode.isHidden = hideNode
		scene.addChild(gridNode)
		
		let worldRadius = Constants.Env.worldRadius
		let boundary = BoundaryComponent.createLoopWall(radius: worldRadius)
		boundary.node?.isHidden = hideNode
		//boundary.addComponent(NoiseComponent())
		scene.addEntity(boundary)
		
		if Constants.Env.addWalls {
			let dim1 = Constants.Env.worldRadius * 0.35
			let dim2 = Constants.Env.worldRadius * 0.25

			let line1 = BoundaryComponent.createVerticalWall(y1: dim1, y2: dim2, x: 0)
			scene.addEntity(line1)
			let line2 = BoundaryComponent.createVerticalWall(y1: -dim2, y2: -dim1, x: 0)
			scene.addEntity(line2)
			let line3 = BoundaryComponent.createHorizontalWall(x1: dim1, x2: dim2, y: 0)
			scene.addEntity(line3)
			let line4 = BoundaryComponent.createHorizontalWall(x1: -dim2, x2: -dim1, y: 0)
			scene.addEntity(line4)
			
			line1.node?.isHidden = hideNode
			line2.node?.isHidden = hideNode
			line3.node?.isHidden = hideNode
			line4.node?.isHidden = hideNode
		}
		
		for _ in 1...Constants.Env.zapperCount {
			let radius = CGFloat.random(in: worldRadius * 0.02...worldRadius * 0.05)
			let position = CGPoint.randomAngle * CGFloat.random(in: 0...worldRadius * 0.8)
			let zapper = ZapperComponent.create(radius: radius, position: position)
			zapper.node?.isHidden = hideNode
			scene.addEntity(zapper)
		}

		let targetAlgaeSupply = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.algaeTarget ?? 0
		let showFountainInfluence = scene.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showAlgaeFountainInfluences ?? false

		// algae fountains
		let alageFountain = ResourceFountainComponent.createFountain(position: .zero, minRadius: worldRadius * 0.1, maxRadius: worldRadius * 0.9, targetAlgaeSupply: targetAlgaeSupply.cgFloat)
		alageFountain.name = "mainFountain"

//		let fountain = ResourceFountainComponent.createFountain(position: CGPoint(angle: 0) * worldRadius * 0.75, minRadius: 0, maxRadius: worldRadius * 0.15, targetAlgaeSupply: targetAlgaeSupply.cgFloat / 4)
//		fountain.name = "fountain"

		if showFountainInfluence {
			alageFountain.addComponent(ResourceFountainInfluenceComponent())
//			fountain.addComponent(ResourceFountainInfluenceComponent())
		}
		scene.addEntity(alageFountain)
//		scene.addEntity(fountain)
 	}
		
	func addNewCell(genome: Genome, in scene: OKScene) -> OKEntity {
		
		let worldRadius = Constants.Env.worldRadius
		let distance = CGFloat.random(in: worldRadius * 0.05...worldRadius * 0.9)
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

		if let hideNode = OctopusKit.shared.currentScene?.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.hideAlgae {
			cell.node?.isHidden = hideNode
		}
		
		return cell
	}
	
	struct IdPair: Equatable {
		var id1: String
		var id2: String
		
		static func == (lhs: Self, rhs: Self) -> Bool {
			return (lhs.id1 == rhs.id1 && lhs.id2 == rhs.id2) || (lhs.id1 == rhs.id2 && lhs.id2 == rhs.id1)
		}
	}
	
	func animateInteraction(sourceCell: CellComponent, targetCell: CellComponent, scene: OKScene) {

		sourceCell.startInteracting()
		targetCell.startInteracting()
		
		for delay: TimeInterval in [0, 0.1, 0.2, 0.3, 0.4, 0.5] {
			let tracerNode = SKShapeNode(circleOfRadius: Constants.Cell.radius * 0.18)
			tracerNode.lineWidth = 0
			tracerNode.fillColor = Int(delay * 10) % 2 == 0 ? .systemRed : .systemBlue
			tracerNode.zPosition = Constants.ZeeOrder.cell - 0.1
			tracerNode.position = sourceCell.entityNode?.position ?? .zero
			let sequence = SKAction.sequence([
				.wait(forDuration: delay),
				.move(to: targetCell.entityNode?.position ?? .zero, duration: 0.5),
				.fadeOutAndRemove(withDuration: 0.05, timingMode: .linear)
			])
			scene.addChild(tracerNode)
			tracerNode.run(sequence)
		}
		
		scene.run(SKAction.wait(forDuration: 0.5)) {
			sourceCell.stopInteracting()
			targetCell.stopInteracting()
		}
	}
	
	func checkMatingPairs() {
		
		guard let scene =  OctopusKit.shared?.currentScene else { return }

		var pairs: [IdPair] = []
		
		let cellsSeeingOtherCells = currentCells.filter({ !$0.expired && $0.coComponent(BrainComponent.self)?.inference.seenId != nil })
		for cell1 in cellsSeeingOtherCells {
			for cell2 in cellsSeeingOtherCells {
				if cell1 != cell2 {

					let id1 = cell1.genome.id
					let id2 = cell2.genome.id

					if 	let seenId1 = cell1.coComponent(BrainComponent.self)?.inference.seenId,
						let seenId2 = cell2.coComponent(BrainComponent.self)?.inference.seenId,
						id1 == seenId2, id2 == seenId1 {
						let pair = IdPair(id1: id1, id2: id2)
						if !pairs.contains(pair) {
							pairs.append(pair)
						}
					}
				}
			}
		}

		for pair in pairs {
			//print("pair: \(pair.id1) and \(pair.id2) are looking at eachother")

			if let cell1 = (scene.entities.filter({ $0.component(ofType: CellComponent.self)?.genome.id == pair.id1 }).first as? OKEntity)?.component(ofType: CellComponent.self),
				let cell2 = (scene.entities.filter({ $0.component(ofType: CellComponent.self)?.genome.id == pair.id2 }).first as? OKEntity)?.component(ofType: CellComponent.self), cell1.canInteract, cell2.canInteract {
				//if let position1 = cell2.entityNode?.position, let position2 = cell2.entityNode?.position, position1.distance(to: position2) >
				animateInteraction(sourceCell: cell1, targetCell: cell2, scene: scene)
				
				[cell1, cell2].forEach { cell in
					cell.energy = cell.maximumEnergy
					cell.stamina = 1
				}
			}
		}

	}
	
	func displayStats() {
		
		guard let scene =  OctopusKit.shared?.currentScene else { return }
		let frame = scene.currentFrameNumber

		if frame.isMultiple(of: 50), let statsComponent = coComponent(GlobalStatsComponent.self) {
			
			let cellCount = scene.entities.filter({ $0.component(ofType: CellComponent.self) != nil }).count
			//let physicsWorldSpeed = coComponent(PhysicsWorldComponent.self)?.physicsWorld?.speed ?? 0

			let cellStats = currentCellStats
			let statsText = "\(Int(frame).abbrev) | pop: \(cellCount)/\(Constants.Env.maximumCells), gen: \(cellStats.minGen)–\(cellStats.maxGen) | e: \(cellStats.avgEnergy.formattedToPercent) | s: \(cellStats.avgStamina.formattedToPercent) | h: \(cellStats.avgHealth.formattedToPercent) | mate: \(cellStats.canMateCount) | preg: \(cellStats.pregnantCount), spawned: \(cellStats.spawnAverage.formattedTo2Places) | alg: \(currentCellStats.resourceStats.algaeTarget.formattedNoDecimal)"

			statsComponent.updateStats(statsText)
			
			if frame > 0, frame.isMultiple(of: 10000) {
				print()
				print(statsText)
				print()
				if let worldScene = scene as? WorldScene {
					worldScene.dumpGenomes()
				}
			}
		}

	}
	
	override func update(deltaTime seconds: TimeInterval) {
		
		guard let scene =  OctopusKit.shared?.currentScene else { return }
		let frame = scene.currentFrameNumber
				
		// key event handling
		if let keyTrackerComponent = coComponent(KeyTrackerComponent.self) {
			for keyCode in keyTrackerComponent.keyCodesDown {
				processWorldKeyDown(keyCode: keyCode, shiftDown: keyTrackerComponent.shiftDown, commandDown: keyTrackerComponent.commandDown)
			}
		}
		
		//checkMatingPairs()
		displayStats()
		
		// cell creation
		if !allGenomesFromFileDispensed, frame >= Constants.Env.startupDelay && frame.isMultiple(of: Constants.Env.dispenseInterval) {
			
			if Constants.Env.randomRun {
				if scene.entities.filter({ $0.component(ofType: CellComponent.self) != nil }).count < Constants.Env.minimumCells {
					let genome = GenomeFactory.shared.newRandomGenome
					let _ = addNewCell(genome: genome, in: scene)
				}
			}
			else if GenomeFactory.shared.genomes.count > 0, scene.entities.filter({ $0.component(ofType: CellComponent.self) != nil }).count < Constants.Env.minimumCells {
				let genomeIndex = genomeDispenseIndex % GenomeFactory.shared.genomes.count
				var genome = GenomeFactory.shared.genomes[genomeIndex]
				genome.id = "\(genome.id)-\(genomeDispenseIndex)"
				print("dispensing genome: \(genome.id) - \(genomeIndex): \(genome.description)")
				let _ = addNewCell(genome: genome, in: scene)
				genomeDispenseIndex += 1
				if genomeDispenseIndex >= GenomeFactory.shared.genomes.count {
					//allGenomesFromFileDispensed = true
				}
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
		var avgStamina: CGFloat
		var avgHealth: CGFloat
		
		var canMateCount: Int
		var pregnantCount: Int
		var spawnAverage: CGFloat
		
		var resourceStats: ResourceStats

		static var zero: CellStats {
			return CellStats(minGen: 0, maxGen: 0, avgEnergy: 0, avgStamina: 0, avgHealth: 0, canMateCount: 0, pregnantCount: 0, spawnAverage: 0, resourceStats: .zero)
		}
	}
	
	var currentCells: [CellComponent] {
		return OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: CellComponent.self) }) ?? []
	}
	
	var currentCellStats: CellStats {
				
		let cells = currentCells
		
		let minGen = cells.map({$0.genome.generation}).min() ?? 0
		let maxGen = cells.map({$0.genome.generation}).max() ?? 0

		let averageEnergy = cells.count == 0 ? 0 : cells.reduce(0) { $0 + $1.energy/$1.maximumEnergy } / cells.count.cgFloat
		let averageStamina = cells.count == 0 ? 0 : cells.reduce(0) { $0 + $1.stamina } / cells.count.cgFloat
		let averageHealth = cells.count == 0 ? 0 : cells.reduce(0) { $0 + $1.health } / cells.count.cgFloat

		let canMateCount = cells.reduce(0) { $0 + ($1.canMate ? 1 : 0) }
		let pregnantCount = cells.reduce(0) { $0 + ($1.isPregnant ? 1 : 0) }
		let spawnAverage = cells.count == 0 ? 0 : CGFloat(cells.reduce(0) { $0 + $1.spawnCount }) / cells.count.cgFloat

		return CellStats(minGen: minGen, maxGen: maxGen, avgEnergy: averageEnergy, avgStamina: averageStamina, avgHealth: averageHealth, canMateCount: canMateCount, pregnantCount: pregnantCount, spawnAverage: spawnAverage, resourceStats: currentResourceStats)
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
