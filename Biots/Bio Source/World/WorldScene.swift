//
//  WorldScene.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018-02-10.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 6B: The "gameplay" scene for the QuickStart project.
//
//  This scene shows the content for multiple game states: PlayState, PausedState and GameOverState.
//
//  The UI is handled by the PlayUI view designed with SwiftUI.

import SpriteKit
import GameplayKit
import OctopusKit

final class WorldScene: OKScene {

	// MARK: - Life Cycle
	var trackedEntity: OKEntity?
	
	// MARK: 🔶 STEP 6B.1
	override func sceneDidLoad() {
    	
    	// Set the name of this scene at the earliest override-able point, for logging purposes.
    	
    	self.name = "BioGenesis World Scene"
    	super.sceneDidLoad()
	}

	// MARK: 🔶 STEP 6B.2
	override func createComponentSystems() -> [GKComponent.Type] {
    	
    	// This method is called by the OKScene superclass, after the scene has been presented in a view, to create a list of systems for each component type that must be updated in every frame of this scene.
    	//
    	// ❗️ The order of components is important, as the functionality of some components depends on the output of other components.
    	//
    	// See the code and documentation for each component to check its requirements.
    	[
	    	// Components that process player input, provided by OctopusKit.
	    	
	    	OSMouseOrTouchEventComponent.self,
	    	PointerEventComponent.self, // This component translates touch or mouse input into an OS-agnostic "pointer" format, which is used by other input-processing components that work on iOS as well as macOS.
			CameraComponent.self,
	    	
	    	// Custom components which are specific to this QuickStart project.
	    	GlobalDataComponent.self,
			PhysicsComponent.self,
			PhysicsEventComponent.self,
			//NoiseComponent.self,
			
			AlgaeComponent.self,
			ResourceFountainComponent.self,
			ResourceFountainInfluenceComponent.self,
			VisionComponent.self,
			ContactComponent.self,
	    	WorldComponent.self,
			BrainComponent.self,
			CellComponent.self,
    	]
	}
	
	// MARK: 🔶 STEP 6B.3
	override func prepareContents() {
    	
    	// This method is called by the OKScene superclass, after the scene has been presented in a view, to let each subclass (the scenes specific to your game) prepare their contents.
    	//
    	// The most common tasks for every scene are to prepare the order of the component systems which the scene will update every frame, and to add entities to the scene.
    	//
    	// Calling super for this method is not necessary; it only adds a log entry.
    	
    	super.prepareContents()
    	    	    	
    	// Create the entities to present in this scene.
		let cameraComponent = CameraComponent()
		if let globalDataComponent = self.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) {
			//print("creating camera, zoom: \(globalDataComponent.cameraZoom)")
			cameraComponent.camera.setScale(CGFloat(globalDataComponent.cameraZoom))
		}

    	// Set the permanent visual properties of the scene itself.
    	self.anchorPoint = CGPoint.half
    			
    	self.entity?.addComponents([
			sharedMouseOrTouchEventComponent,
			sharedPointerEventComponent,
			PhysicsWorldComponent(),
			sharedPhysicsEventComponent,
			cameraComponent,
			KeyTrackerComponent(),
			GlobalStatsComponent(),
		])
    	    	
    	// Add the global game coordinator entity to this scene so that global components will be included in the update cycle, and updated in the order specified by this scene's `componentSystems` array.
    	if let gameCoordinatorEntity = OctopusKit.shared?.gameCoordinator.entity {
	    	self.addEntity(gameCoordinatorEntity)
    	}
	}
	
	func dumpPlaceables() {
		print("\n[")
		
		var nodePlacements: [NodePlacement] = []
		
		for component in entities(withName: "zapper")?.map({$0.component(ofType: ZapperComponent.self)}) as? [ZapperComponent] ?? [] {
			if let node = component.entityNode {
				nodePlacements.append(node.createNodePlacement(placeableType: .zapper, radius: component.radius))
			}
		}
		
		for component in entities(withName: "water")?.map({$0.component(ofType: WaterSourceComponent.self)}) as? [WaterSourceComponent] ?? [] {
			if let node = component.entityNode {
				nodePlacements.append(node.createNodePlacement(placeableType: .water, radius: component.radius))
			}
		}

		var index = 0
		for placement in nodePlacements {
			if let jsonData = try? placement.encodedToJSON() {
				if let jsonString = String(data: jsonData, encoding: .utf8) {
					let delim = index == nodePlacements.count-1 ? "" : ","
					print("\(jsonString)\(delim)")
				}
			}
			index += 1
		}
		
		print("]\n")
	}
	
	func dumpGenomes() {
		print("\n[")
		var genomes = self.entities.filter({ $0.component(ofType: CellComponent.self) != nil }).map({$0.component(ofType: CellComponent.self)}).map({$0?.genome})
		if let unbornCells = (entity?.component(ofType: WorldComponent.self))?.unbornGenomes {
			let unborn = Array(unbornCells.suffix(10))
			genomes.append(contentsOf: unborn)
		}
		
		var index = 0
		for genome in genomes {
			if let jsonData = try? genome.encodedToJSON() {
				if let jsonString = String(data: jsonData, encoding: .utf8) {
					let delim = index == genomes.count-1 ? "" : ","
					print("\(jsonString)\(delim)")
				}
			}
			index += 1
		}
		
		print("]\n")
	}
	
	func cellEntityById(_ id: String) -> CellComponent? {
		return (entities.filter({ $0.component(ofType: CellComponent.self)?.genome.id == id }).first as? OKEntity)?.component(ofType: CellComponent.self)
	}
	
	func trackEntity() {
		if let cameraComponent = entity?.component(ofType: CameraComponent.self), let node = trackedEntity?.node {
			cameraComponent.nodeToTrack = nil
			cameraComponent.camera.run(SKAction.move(to: node.position, duration: 0.5)) {
				cameraComponent.nodeToTrack = node
			}
		}
	}
	
	func stopTrackingEntity() {
		if let cameraComponent = entity?.component(ofType: CameraComponent.self) {
			trackedEntity = nil
			cameraComponent.nodeToTrack = nil
		}
	}
	
	func selectMostFit() {
		if let cameraComponent = entity?.component(ofType: CameraComponent.self), let cellComponents = entities(withName: "cell")?.map({$0.component(ofType: CellComponent.self)}) as? [CellComponent] {
			if let mostFit = cellComponents.sorted(by: { (cell1, cell2) -> Bool in
				return cell1.health > cell2.health
			}).first {
				cameraComponent.nodeToTrack = mostFit.entityNode
				trackedEntity = mostFit.entity as? OKEntity
			}
		}
	}
	
	override func keyDown(with event: NSEvent) {
		
		guard let globalDataComponent = self.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) else {
			OctopusKit.logForErrors.add("could get GlobalDataComponent")
			return
		}
		
		let shiftDown = event.modifierFlags.contains(.shift)
		let commandDown = event.modifierFlags.contains(.command)
		let keyDownCode = event.keyCode

		//print("keyDown: \(event.characters ?? ""), keyDownCode: \(keyDownCode), shiftDown: \(shiftDown), commandDown: \(commandDown)")
				
		switch event.keyCode {
				
		case Keycode.r:
			if shiftDown, commandDown, Constants.Env.randomRun {
				entities(withName: "cell")?.forEach({ cellEntity in
					removeEntity(cellEntity)
				})
			}
			break
						
		case Keycode.h:
			globalDataComponent.showCellHealth.toggle()
			break
			
		case Keycode.v:
			if shiftDown {
				globalDataComponent.showCellVisionTracer.toggle()
			} else {
				globalDataComponent.showCellVision.toggle()
			}
			break

		case Keycode.t:
			globalDataComponent.showCellThrust.toggle()
			break

		case Keycode.a:
			if commandDown {
				globalDataComponent.hideSpriteNodes.toggle()
				entities(withName: "algae")?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})
				
				entities(withName: "cell")?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})
				
				entities(withName: "wall")?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})
				
				entities(withName: "zapper")?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})

				entities(withName: "water")?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})

				scene?.children.filter({$0.name == "grid"}).first?.isHidden = globalDataComponent.hideSpriteNodes
				return
			}
			
			selectMostFit()
			break

		case Keycode.e:
			globalDataComponent.showCellEyeSpots.toggle()
			self.entities.filter { $0.component(ofType: CellComponent.self) != nil }.forEach({ cell in
				if globalDataComponent.showCellEyeSpots {
					cell.addComponent(EyesComponent())
				}
				else {
					cell.removeComponent(ofType: EyesComponent.self)
				}
			})
			
		case Keycode.s:
			if commandDown, shiftDown {
				dumpPlaceables()
				return
			}
			else if commandDown {
				dumpGenomes()
				return
			}
			else {
				globalDataComponent.showCellStats.toggle()
				self.entities.filter { $0.component(ofType: CellComponent.self) != nil }.forEach({ cell in
					if globalDataComponent.showCellStats {
						if cell.component(ofType: EntityStatsComponent.self) == nil {
							cell.addComponent(EntityStatsComponent())
						}
					}
					else {
						cell.removeComponent(ofType: EntityStatsComponent.self)
					}
				})
			}
			
		case Keycode.p:
			globalDataComponent.showPhysics.toggle()
			self.view?.showsPhysics = globalDataComponent.showPhysics
						
		case Keycode.f:
						
			if commandDown {
				globalDataComponent.showAlgaeFountainInfluences.toggle()
				self.entities.filter { $0.component(ofType: ResourceFountainComponent.self) != nil }.forEach({ fountain in
					if globalDataComponent.showAlgaeFountainInfluences {
						fountain.addComponent(ResourceFountainInfluenceComponent())
					}
					else {
						fountain.removeComponent(ofType: ResourceFountainInfluenceComponent.self)
					}
				})
				return
			}
			
			let bump = 1000 * (shiftDown ? -1 : 1)
			if globalDataComponent.algaeTarget + bump >= 0 {
				globalDataComponent.algaeTarget += bump
				
				self.entities(withName: "mainFountain")?.first?.component(ofType: ResourceFountainComponent.self)?.targetAlgaeSupply = globalDataComponent.algaeTarget.cgFloat
				self.entities(withName: "fountain")?.map({$0.component(ofType: ResourceFountainComponent.self)}).forEach({ fountainComponent in
					fountainComponent?.targetAlgaeSupply = globalDataComponent.algaeTarget.cgFloat / 4
				})
			}
			
		case Keycode.tab:
			if let cells = entities(withName: "cell") {
				if trackedEntity == nil {
					trackedEntity = cells.first
					trackEntity()
				}
				else if cells.count > 1 {
					if let index = cells.firstIndex(of: trackedEntity!) {

						let direction = shiftDown ? -1 : 1
						let nextIndex = (index + direction + cells.count) % cells.count
						trackedEntity = cells[nextIndex]
						trackEntity()
					}
				}
			}

		case Keycode.space:
			//scene!.isPaused = !scene!.isPaused
			togglePauseByPlayer()
			self.entity?.component(ofType: KeyTrackerComponent.self)?.clearKeysDown()
			self.entity?.component(ofType: GlobalStatsComponent.self)?.setPaused(isPausedByPlayer)

		case Keycode.k:
			if commandDown {
				var cells = OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: CellComponent.self) }) ?? []
				cells = cells.filter({ $0.health < 0.25 })
				cells.forEach({ $0.kill() })
				return
			}
			
			if trackedEntity != nil, let cell = trackedEntity?.component(ofType: CellComponent.self) {
				cell.kill()
				trackedEntity = nil
				
				if shiftDown {
					selectMostFit()
				}
			}
			
		default:
			if let tracker = self.entity?.component(ofType: KeyTrackerComponent.self) {
				tracker.keyDown(keyCode: keyDownCode, shiftDown: shiftDown, commandDown: commandDown)
			}
		}
	}
	
	override func keyUp(with event: NSEvent) {
		
		//guard !scene!.isPaused && !isPausedByPlayer && !isPausedBySystem && !isPausedBySubscene else { return }
		
		let shiftDown = event.modifierFlags.contains(.shift)
		let commandDown = event.modifierFlags.contains(.command)
		let keyUpCode = event.keyCode
		
		//print("keyUp: \(event.characters ?? "") keyUpCode: \(keyUpCode), shiftDown: \(shiftDown), commandDown: \(commandDown)")
		if let tracker = self.entity?.component(ofType: KeyTrackerComponent.self) {
			tracker.keyUp(keyCode: keyUpCode, shiftDown: shiftDown, commandDown: commandDown)
		}
	}
	
	var draggingNode: SKNode? = nil
	var resizing = false
	var lastDragPoint: CGPoint = .zero
	
	override func mouseDragged(with event: NSEvent) {
		//print(event.location(in: self).formattedTo2Places)
		if draggingNode != nil {
			stopTrackingEntity()
			if resizing {
				let offset: CGFloat = 5
				if let selectedEntity = entities.filter({ $0.node == draggingNode }).first as? OKEntity {
					if let zapperComponent = selectedEntity.component(ofType: ZapperComponent.self) {
						let delta: CGFloat = (draggingNode?.position ?? .zero).y - event.location(in: self).y > 0 ? -offset : offset
						if !((zapperComponent.radius < 50 && delta < 0) || (zapperComponent.radius > 800 && delta > 0)) {
							zapperComponent.radius += delta
							zapperComponent.entityNode?.setScale(zapperComponent.radius / (zapperComponent.radius-delta) * (zapperComponent.entityNode?.xScale ?? 1))
						}
					}
					else if let waterComponent = selectedEntity.component(ofType: WaterSourceComponent.self) {
						let delta: CGFloat = (draggingNode?.position ?? .zero).y - event.location(in: self).y > 0 ? -offset : offset
						if !((waterComponent.radius < 50 && delta < 0) || (waterComponent.radius > 800 && delta > 0)) {
							waterComponent.radius += delta
							waterComponent.entityNode?.setScale(waterComponent.radius / (waterComponent.radius-delta) * (waterComponent.entityNode?.xScale ?? 1))
						}
					}
				}
			}
			else {
				draggingNode?.position = event.location(in: self) - lastDragPoint
			}
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		let commandDown = event.modifierFlags.contains(.command)
		let shiftDown = event.modifierFlags.contains(.shift)
		self.touchDown(at: event.location(in: self), commandDown: commandDown, shiftDown: shiftDown, clickCount: event.clickCount)
	}
	
	override func mouseUp(with event: NSEvent) {
		draggingNode = nil
		resizing = false
		lastDragPoint = .zero
	}
	
	override func rightMouseDown(with event: NSEvent) {
		let commandDown = event.modifierFlags.contains(.command)
		self.touchDown(at: event.location(in: self), rightMouse: true, commandDown: commandDown)
	}
	
	func touchDown(at point: CGPoint, rightMouse: Bool = false, commandDown: Bool = false, shiftDown: Bool = false, clickCount: Int = 1) {
		
		guard let keyCodesDown = self.entity?.component(ofType: KeyTrackerComponent.self)?.keyCodesDown,
			  let mainFountain = entities(withName: "mainFountain")?.first?.component(ofType: ResourceFountainComponent.self) else {
			return
		}
		
		if keyCodesDown.contains(Keycode.w) {
			let radius: CGFloat = 200
			let water = WaterSourceComponent.create(radius: radius, position: point)
			mainFountain.waterEntities.append(water)
			addEntity(water)
			return
		}
		
		if keyCodesDown.contains(Keycode.b) {
			let radius: CGFloat = 200
			let zapper = ZapperComponent.create(radius: radius, position: point)
			addEntity(zapper)
			return
		}
				
		if let cellNode = nodes(at: point).filter({$0.name == "cell"}).first {
			//print(cellNode.position)
			
			if let selectedEntity = entities.filter({ $0.node == cellNode }).first as? OKEntity,
				let cellComponent = selectedEntity.component(ofType: CellComponent.self) {
				
				if cellComponent.isInteracting, clickCount == 2 {
					cellComponent.isInteracting = false
					return
				}
				
				if shiftDown, commandDown, Constants.Env.randomRun {
					entities(withName: "cell")?.forEach({ cellEntity in
						removeEntity(cellEntity)
					})
					
					let worldRadius = Constants.Env.worldRadius

					for _ in 1...Constants.Env.minimumCells {
						let distance = CGFloat.random(in: Constants.Env.worldRadius * 0.05...worldRadius * 0.9)
						let position = CGPoint.randomDistance(distance)
						let clonedGenome = Genome(parent: cellComponent.genome)
						let childCell = CellComponent.createCell(genome: clonedGenome, at: position, fountainComponent: RelayComponent(for: mainFountain))
						addEntity(childCell)
					}
				}
				else if commandDown, let cameraComponent = entity?.component(ofType: CameraComponent.self) {
					if cameraComponent.nodeToTrack == selectedEntity.node {
						cameraComponent.nodeToTrack = nil
					}
					else {
						cameraComponent.nodeToTrack = selectedEntity.node
					}
				}
				else if rightMouse {
					cellComponent.kill()
				}
				else if shiftDown {
					if let jsonData = try? cellComponent.genome.encodedToJSON() {
						if let jsonString = String(data: jsonData, encoding: .utf8) {
							print("\(jsonString),")
						}
					}
					cellComponent.mated(otherGenome: cellComponent.genome)
					cellComponent.spawnChildren(selfReplication: true)
					cellComponent.foodEnergy = cellComponent.maximumEnergy
					cellComponent.hydration = Constants.Cell.maximumHydration
					return
				}
				else if !rightMouse, let cellNode = nodes(at: point).filter({$0.name == "cell"}).first,
						let selectedEntity = entities.filter({ $0.node == cellNode }).first as? OKEntity,
						let cellComponent = selectedEntity.component(ofType: CellComponent.self) {
					draggingNode = cellNode
					lastDragPoint = point - cellNode.position
					cellComponent.isInteracting = true
				}
			}
		}
		else if !rightMouse, let waterNode = nodes(at: point).filter({$0.name == "water"}).first {
			draggingNode = waterNode
			resizing = shiftDown
			lastDragPoint = point - waterNode.position
		}
		else if !rightMouse, let zapperNode = nodes(at: point).filter({$0.name == "zapper"}).first {
			draggingNode = zapperNode
			resizing = shiftDown
			lastDragPoint = point - zapperNode.position
		}
		else if rightMouse, let waterNode = nodes(at: point).filter({$0.name == "water"}).first, let selectedEntity = entities.filter({ $0.node == waterNode }).first as? OKEntity {
			removeEntity(selectedEntity)
		}
		else if rightMouse, let zapperNode = nodes(at: point).filter({$0.name == "zapper"}).first, let selectedEntity = entities.filter({ $0.node == zapperNode }).first as? OKEntity {
			removeEntity(selectedEntity)
		}
		else if shiftDown, !commandDown {
			for _ in 1...3 + Int.random(3) {
				let algae = mainFountain.createAlgaeEntity(energy: Constants.Algae.bite * Int.random(in: 2...5).cgFloat)
				if let node = algae.component(ofType: SpriteKitComponent.self)?.node {
					node.position = point + CGPoint.randomAngle * CGFloat.random(in: 50..<200)
					addEntity(algae)
				}
			}
			return
		}

	}

	// MARK: - State & Scene Transitions
	
	// MARK: 🔶 STEP 6B.4
	override func gameCoordinatorDidEnterState(_ state: GKState, from previousState: GKState?) {
    	
    	// This method is called by the current game state to notify the current scene when a new state has been entered.
    	//
    	// Calling super for this method is not necessary; it only adds a log entry.
    	
    	super.gameCoordinatorDidEnterState(state, from: previousState)
    	
    	// If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
    	
    	switch type(of: state) {
	    	
    	case is PlayState.Type: // Entering `PlayState`

			self.entity?.component(ofType: KeyTrackerComponent.self)?.clearKeysDown()
	    	self.backgroundColor = Constants.Colors.background
	    	self.entity?.addComponent(WorldComponent())
						
			self.view?.showsFPS = Constants.Env.showSpriteKitStats
//			self.view?.showsNodeCount = Constants.Environment.showSpriteKitStats
//			self.view?.showsDrawCount = Constants.Environment.showSpriteKitStats
			self.view?.showsPhysics = self.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showPhysics ?? false
			self.view?.ignoresSiblingOrder = true
			self.view?.preferredFramesPerSecond = 30
			self.physicsWorld.gravity = .zero
//			self.physicsWorld.speed = 4
//			OctopusKit.shared.currentScene?.physicsWorld.speed = 4
//			entity?.component(ofType: PhysicsWorldComponent.self)?.physicsWorld?.speed = 4

//			let noise = SKFieldNode.noiseField(withSmoothness: 0.5, animationSpeed: 0.25)
//			noise.strength = Constants.Environment.worldRadius.float * 0.01
//			addChild(noise)
			
//			let turbulence = SKFieldNode.turbulenceField(withSmoothness: 0.9, animationSpeed: 0.05)
//			turbulence.strength = 2
//			addChild(turbulence)
			
//			let mag = SKFieldNode.springField()
//			mag.strength = 0.01
//			addChild(mag)

	    	// Add a fade-in effect if the previous state and scene was the title screen.
	    	if previousState is TitleState {
				let colorFill = SKSpriteNode(color: .white, size: self.frame.size)
				colorFill.alpha = 1
				colorFill.blendMode = .replace
				self.addChild(colorFill)
				let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1.5).withTimingMode(.easeIn)
				colorFill.run(.sequence([fadeOut, .removeFromParent()]))
	    	}
	    	
    	case is PausedState.Type: // Entering `PausedState`
	    	
	    	self.backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
	    	
	    	// Remove the global entity from this scene so we do not update it until the game is unpaused.
	    	if let gameCoordinatorEntity = OctopusKit.shared?.gameCoordinator.entity {
    	    	self.removeEntity(gameCoordinatorEntity)
	    	}
	    	
	    	// Set the scene's "paused by player" flag, because the PausedState is a state which is specific to this QuickStart project, not a feature of OctopusKit. When we manually enter this state, we must also notify OctopusKit that the player has chosen to pause the game.
	    	if !isPausedByPlayer { togglePauseByPlayer() }
	    	
    	case is GameOverState.Type: // Entering `GameOverState`
	    	self.backgroundColor = SKColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 1.0)
	    	
    	default: break
    	}
	}
	
	// MARK: 🔶 STEP 6B.5
	override func gameCoordinatorWillExitState(_ exitingState: GKState, to nextState: GKState) {
    	
    	// This method is called by the current game state to notify the current scene when the state will transition to a new state.
    	
    	super.gameCoordinatorWillExitState(exitingState, to: nextState)
    	
    	// If this scene needs to perform tasks which are common to every state, you may put that code outside the switch statement.
    	
    	switch type(of: exitingState) {
    	
    	case is PlayState.Type: // Exiting `PlayState`
	    	
	    	self.entity?.removeComponent(ofType: WorldComponent.self)
	    	
    	case is PausedState.Type: // Exiting `PausedState`
	    	
	    	// Add the global entity back to this scene so we can resume updating it.
	    	
	    	if let gameCoordinatorEntity = OctopusKit.shared?.gameCoordinator.entity {
    	    	self.addEntity(gameCoordinatorEntity)
	    	}
	    	
	    	// Clear the scene's "paused by player" flag,
	    	
	    	if isPausedByPlayer { togglePauseByPlayer() }
	    	
    	default: break
    	}
    	
	}
	
	// MARK: 🔶 STEP 6B.6
	override func transition(for nextSceneClass: OKScene.Type) -> SKTransition? {
    	
    	// This method is called by the OKScenePresenter to ask the current scene for a transition animation between the outgoing scene and the next scene.
    	//
    	// Here we display transition effects if the next scene is the TitleScene.
    	
    	guard nextSceneClass is TitleScene.Type else { return nil }
    	
    	// First, apply some effects to the current scene.
    	
    	let colorFill = SKSpriteNode(color: .black, size: self.frame.size)
    	colorFill.alpha = 0
    	colorFill.zPosition = 1000
    	self.addChild(colorFill)
    	
    	let fadeOut = SKAction.fadeAlpha(to: 1.0, duration: 1.0).withTimingMode(.easeIn)
    	colorFill.run(fadeOut)
    	
    	// Next, provide the OKScenePresenter with an animation to apply between the contents of this scene and the upcoming scene.
    	
    	let transition = SKTransition.doorsCloseVertical(withDuration: 2.0)
    	
    	transition.pausesOutgoingScene = false
    	transition.pausesIncomingScene = false
    	
    	return transition
	}
	
	// MARK: - Pausing/Unpausing
	
	override func applicationWillResignActive() {
		// override to not pause by system
	}
	
	override func didPauseBySystem() {
    	
    	// 🔶 STEP 6B.?: This method is called when the player switches to a different application, or the device receives a phone call etc.
    	//
    	// Here we enter the PausedState if the game was in the PlayState.
    	
//    	if  let currentState = OctopusKit.shared?.gameCoordinator.currentState,
//	    	type(of: currentState) is PlayState.Type
//    	{
//	    	self.octopusSceneDelegate?.octopusScene(self, didRequestGameState: PausedState.self)
//    	}
	}

	override func didPauseByPlayer() {
	   self.physicsWorld.speed = 0
    	self.isPaused = true
	}
	
	override func didUnpauseByPlayer() {
		self.physicsWorld.speed = 1
    	self.isPaused = false
	}
}



// NEXT: See PlayUI (STEP 6C) and PausedState (STEP 7)

