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
    	
    	self.name = "Biots World Scene"
    	super.sceneDidLoad()
		
//		if let globalDataComponent = self.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) {
//			globalDataComponent.reset()
//		}
	}
	
	override func didMove(to: SKView) {
		super.didMove(to: to)
		
		// from ShinryakuTako: Steal the focus on macOS so the player doesn't have to click on the view before using the keyboard.
		#if os(macOS)
		to.window?.makeFirstResponder(self)
		
		// CHECK: why is no cursor stuff working?
		//to.window?.enableCursorRects()
		to.addCursorRect(to.bounds, cursor: .pointingHand)
		//NSCursor.pointingHand.set()

		#endif
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
			
			// biots components that require update() to be called
			AlgaeComponent.self,
			ResourceFountainComponent.self,
			ResourceFountainInfluenceComponent.self,
			VisionComponent.self,
			ContactComponent.self,
	    	WorldComponent.self,
			BrainComponent.self,
			BiotComponent.self,
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
			cameraComponent.camera.position = CGPoint(x: CGFloat(globalDataComponent.cameraX), y: CGFloat(globalDataComponent.cameraY))
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
			GlobalStatsComponent(pointerEventComponent: sharedPointerEventComponent),
		])
    	    	
    	// Add the global game coordinator entity to this scene so that global components will be included in the update cycle, and updated in the order specified by this scene's `componentSystems` array.
    	if let gameCoordinatorEntity = OctopusKit.shared?.gameCoordinator.entity {
	    	self.addEntity(gameCoordinatorEntity)
    	}
	}
	
	var currentWorldObjects: [WorldObject] {
	
		var worldObjects: [WorldObject] = []
		
		for component in entities(withName: Constants.NodeName.zapper)?.map({$0.component(ofType: ZapperComponent.self)}) as? [ZapperComponent] ?? [] {
			if let node = component.entityNode {
				worldObjects.append(node.createWorldObject(placeableType: .zapper, radius: component.radius))
			}
		}
		
		for component in entities(withName: Constants.NodeName.water)?.map({$0.component(ofType: WaterSourceComponent.self)}) as? [WaterSourceComponent] ?? [] {
			if let node = component.entityNode {
				worldObjects.append(node.createWorldObject(placeableType: .water, radius: component.radius))
			}
		}
		
		return worldObjects.compactMap { $0 }
	}
	
	func dumpPlaceables() {
		print("\n[")
		
		let worldObjects = currentWorldObjects
		
		var index = 0
		for worldObject in worldObjects {
			if let jsonData = try? worldObject.encodedToJSON() {
				if let jsonString = String(data: jsonData, encoding: .utf8) {
					let delim = index == worldObjects.count-1 ? "" : ","
					print("\(jsonString)\(delim)")
				}
			}
			index += 1
		}
		
		print("]\n")
	}
	
	var currentGenomes: [Genome] {
		var genomes = self.entities.filter({ $0.component(ofType: BiotComponent.self) != nil }).map({$0.component(ofType: BiotComponent.self)}).map({$0?.genome})
		
		if let unbornBiots = (entity?.component(ofType: WorldComponent.self))?.unbornGenomes {
			let unborn = Array(unbornBiots.suffix(10))
			genomes.append(contentsOf: unborn)
		}
		
		return genomes.compactMap { $0 }
	}
	
	func dumpGenomes() {
		print("\n[")
		let genomes = currentGenomes
		
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
	
	func biotEntityById(_ id: String) -> BiotComponent? {
		return (entities.filter({ $0.component(ofType: BiotComponent.self)?.genome.id == id }).first as? OKEntity)?.component(ofType: BiotComponent.self)
	}
	
	func trackEntity(_ trackedEntity: OKEntity) {
		
		stopTrackingEntity()
			
		if let biotComponent = trackedEntity.component(ofType: BiotComponent.self) {
			biotComponent.setSelected(true)
		}
		self.trackedEntity = trackedEntity
		if let cameraComponent = entity?.component(ofType: CameraComponent.self), let node = trackedEntity.node {
			cameraComponent.nodeToTrack = nil
			cameraComponent.camera.run(SKAction.move(to: node.position, duration: 0.5)) {
				cameraComponent.nodeToTrack = node
			}
		}
	}
	
	func stopTrackingEntity() {

		if let biotComponent = trackedEntity?.component(ofType: BiotComponent.self) {
			biotComponent.setSelected(false)
		}

		if let cameraComponent = entity?.component(ofType: CameraComponent.self), let globalDataComponent = self.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) {
			globalDataComponent.cameraX = Double(cameraComponent.camera.position.x)
			globalDataComponent.cameraY = Double(cameraComponent.camera.position.y)
			trackedEntity = nil
			cameraComponent.nodeToTrack = nil
		}
	}
	
	func selectMostFit() {
		if let biotComponents = entities(withName: Constants.NodeName.biot)?.map({$0.component(ofType: BiotComponent.self)}) as? [BiotComponent] {
			if let mostFit = biotComponents.sorted(by: { (biot1, biot2) -> Bool in
				return biot1.health > biot2.health
			}).first, let mostFitEntity = mostFit.entity as? OKEntity, mostFitEntity != trackedEntity {
				trackEntity(mostFitEntity)
			}
		}
	}
	
	func selectLeastFit() {
		if let biotComponents = entities(withName: Constants.NodeName.biot)?.map({$0.component(ofType: BiotComponent.self)}) as? [BiotComponent] {
			if let mostFit = biotComponents.sorted(by: { (biot1, biot2) -> Bool in
				return biot1.health < biot2.health
			}).first, let mostFitEntity = mostFit.entity as? OKEntity, mostFitEntity != trackedEntity {
				trackEntity(mostFitEntity)
			}
		}
	}
	
	func showBiotStats(_ showBiotStats: Bool) {
		self.entities.filter { $0.component(ofType: BiotComponent.self) != nil }.forEach({ biot in
			if showBiotStats {
				if biot.component(ofType: EntityStatsComponent.self) == nil {
					biot.addComponent(EntityStatsComponent())
				}
			}
			else {
				if let statsComponent = biot.component(ofType: EntityStatsComponent.self) {
					statsComponent.statsNode.run(SKAction.fadeOut(withDuration: 0.25)) {
						biot.removeComponent(ofType: EntityStatsComponent.self)
					}
				}
			}
		})
	}
	
	func setAlgaeTargetsInFountains(_ algaeTarget: Int) {
		self.entities(withName: "mainFountain")?.first?.component(ofType: ResourceFountainComponent.self)?.targetAlgaeSupply = algaeTarget.cgFloat
		self.entities(withName: "fountain")?.map({$0.component(ofType: ResourceFountainComponent.self)}).forEach({ fountainComponent in
			fountainComponent?.targetAlgaeSupply = algaeTarget.cgFloat / 4
		})
	}
	
	override func keyDown(with event: NSEvent) {
		
		guard let globalDataComponent = self.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self) else {
			OctopusKit.logForErrors.add("could get GlobalDataComponent")
			return
		}
		
		guard let gameConfig = GameManager.shared.gameConfig else {
			return
		}
		
		let shiftDown = event.modifierFlags.contains(.shift)
		let commandDown = event.modifierFlags.contains(.command)
		let optionDown = event.modifierFlags.contains(.option)
		let keyDownCode = event.keyCode

		if let tracker = self.entity?.component(ofType: KeyTrackerComponent.self) {
			tracker.keyDown(keyCode: keyDownCode, shiftDown: shiftDown, commandDown: commandDown)
		}

		//print("keyDown: \(event.characters ?? ""), keyDownCode: \(keyDownCode), shiftDown: \(shiftDown), commandDown: \(commandDown), optionDown: \(optionDown)")
				
		switch event.keyCode {
		
		case Keycode.u:
			globalDataComponent.showHUDPub.toggle()
			break
		
		case Keycode.r:
			if shiftDown, commandDown, gameConfig.gameMode == .random {
				entities(withName: Constants.NodeName.biot)?.forEach({ biotEntity in
					removeEntity(biotEntity)
				})
			}
			break
						
		case Keycode.h:
			if shiftDown {
				globalDataComponent.showBiotHealthDetails.toggle()
			} else {
				globalDataComponent.showBiotHealth.toggle()
			}
			break
			
		case Keycode.v:
			if shiftDown {
				globalDataComponent.showBiotVisionTracer.toggle()
			} else {
				globalDataComponent.showBiotVision.toggle()
			}
			break

		case Keycode.t:
			globalDataComponent.showBiotThrust.toggle()
			break

		case Keycode.a:
			if commandDown {
				globalDataComponent.hideSpriteNodes.toggle()
				entities(withName: Constants.NodeName.algae)?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})
				
				entities(withName: Constants.NodeName.biot)?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})
				
				entities(withName: Constants.NodeName.wall)?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})
				
				entities(withName: Constants.NodeName.zapper)?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})

				entities(withName: Constants.NodeName.water)?.forEach({ entity in
					entity.node?.isHidden = globalDataComponent.hideSpriteNodes
				})
				
				scene?.children.filter({$0.name == Constants.NodeName.grid }).first?.isHidden = globalDataComponent.hideSpriteNodes
				return
			}
			
			if shiftDown {
				selectLeastFit()
			} else {
				selectMostFit()
			}
			break

		case Keycode.d:
			if globalDataComponent.showBiotHealth || globalDataComponent.showBiotVision || globalDataComponent.showBiotThrust {
				globalDataComponent.showBiotHealth = false
				globalDataComponent.showBiotVision = false
				globalDataComponent.showBiotThrust = false
			}
			else  {
				globalDataComponent.showBiotHealth = true
				globalDataComponent.showBiotVision = true
				globalDataComponent.showBiotThrust = true
			}
			break
			
		case Keycode.e:
			globalDataComponent.showBiotEyeSpots.toggle()
			self.entities.filter { $0.component(ofType: BiotComponent.self) != nil }.forEach({ biot in
				if globalDataComponent.showBiotEyeSpots {
					biot.addComponent(EyesComponent())
				}
				else {
					biot.removeComponent(ofType: EyesComponent.self)
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
			else if shiftDown {
				self.entity?.component(ofType: GlobalStatsComponent.self)?.toggleVisibility()

			}
			else {
				globalDataComponent.showBiotStats.toggle()
				showBiotStats(globalDataComponent.showBiotStats)
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
			else if optionDown {
				let bump = 1000 * (shiftDown ? -1 : 1)
				if globalDataComponent.algaeTarget + bump >= 0, globalDataComponent.algaeTarget + bump <= 20000 {
					globalDataComponent.algaeTarget += bump
					setAlgaeTargetsInFountains(globalDataComponent.algaeTarget)
				}
			}
			break


		case Keycode.tab:
			if let biots = entities(withName: Constants.NodeName.biot), let firstBiot = biots.first {
				if trackedEntity == nil {
					trackEntity(firstBiot)
				}
				else if biots.count > 1 {
					if let index = biots.firstIndex(of: trackedEntity!) {

						let direction = shiftDown ? -1 : 1
						let nextIndex = (index + direction + biots.count) % biots.count
						trackEntity(biots[nextIndex])
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
				var biots = OctopusKit.shared.currentScene?.entities.compactMap({ $0.component(ofType: BiotComponent.self) }) ?? []
				biots = biots.filter({ $0.health < 0.25 })
				biots.forEach({ $0.kill() })
				return
			}
			
			if trackedEntity != nil, let biot = trackedEntity?.component(ofType: BiotComponent.self) {
				biot.kill()				
				if shiftDown {
					selectMostFit()
				}
			}
			
		default: break
		}
	}
	
	override func keyUp(with event: NSEvent) {
		
		//guard !scene!.isPaused && !isPausedByPlayer && !isPausedBySystem && !isPausedBySubscene else { return }
		
		let shiftDown = event.modifierFlags.contains(.shift)
		let commandDown = event.modifierFlags.contains(.command)
		let optionDown = event.modifierFlags.contains(.option)
		let keyUpCode = event.keyCode
		
		//print("keyUp: \(event.characters ?? "") keyUpCode: \(keyUpCode), shiftDown: \(shiftDown), commandDown: \(commandDown)")
		if let tracker = self.entity?.component(ofType: KeyTrackerComponent.self) {
			tracker.keyUp(keyCode: keyUpCode, shiftDown: shiftDown, commandDown: commandDown, optionDown: optionDown)
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
						if !((zapperComponent.radius < Constants.Resource.minSize && delta < 0) || (zapperComponent.radius > Constants.Resource.maxSize && delta > 0)) {
							zapperComponent.radius += delta
							zapperComponent.entityNode?.setScale(zapperComponent.radius / (zapperComponent.radius-delta) * (zapperComponent.entityNode?.xScale ?? 1))
						}
					}
					else if let waterComponent = selectedEntity.component(ofType: WaterSourceComponent.self) {
						let delta: CGFloat = (draggingNode?.position ?? .zero).y - event.location(in: self).y > 0 ? -offset : offset
						if !((waterComponent.radius < Constants.Resource.minSize && delta < 0) || (waterComponent.radius > Constants.Resource.maxSize && delta > 0)) {
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
		let optionDown = event.modifierFlags.contains(.option)
		self.touchDown(at: event.location(in: self), commandDown: commandDown, shiftDown: shiftDown, optionDown: optionDown, clickCount: event.clickCount)
	}
	
	override func mouseUp(with event: NSEvent) {
		draggingNode = nil
		resizing = false
		lastDragPoint = .zero
	}
	
	override func rightMouseDown(with event: NSEvent) {
		let commandDown = event.modifierFlags.contains(.command)
		let shiftDown = event.modifierFlags.contains(.shift)
		let optionDown = event.modifierFlags.contains(.option)
		self.touchDown(at: event.location(in: self), rightMouse: true, commandDown: commandDown, shiftDown: shiftDown, optionDown: optionDown)
	}
	
	func touchDown(at point: CGPoint, rightMouse: Bool = false, commandDown: Bool = false, shiftDown: Bool = false, optionDown: Bool = false, clickCount: Int = 1) {
		
		guard let keyCodesDown = self.entity?.component(ofType: KeyTrackerComponent.self)?.keyCodesDown,
			  let mainFountain = entities(withName: "mainFountain")?.first?.component(ofType: ResourceFountainComponent.self) else {
			return
		}

		guard let gameConfig = GameManager.shared.gameConfig else {
			return
		}

		//print("touchDown: point: \(point.formattedTo2Places), keyCodesDown: \(keyCodesDown), shiftDown: \(shiftDown), commandDown: \(commandDown), optionDown: \(optionDown)")
		
		if keyCodesDown.contains(Keycode.w) {
			let radius: CGFloat = Constants.Resource.plopSize
			let water = WaterSourceComponent.create(radius: radius, position: point)
			mainFountain.waterEntities.append(water)
			addEntity(water)
			return
		}
		
		if keyCodesDown.contains(Keycode.b) {
			let radius: CGFloat = Constants.Resource.plopSize
			let zapper = ZapperComponent.create(radius: radius, position: point)
			addEntity(zapper)
			return
		}
				
		if keyCodesDown.contains(Keycode.f) {
			for _ in 1...3 + Int.random(3) {
				let algae = mainFountain.createAlgaeEntity(energy: Constants.Algae.bite * Int.random(in: 2...5).cgFloat)
				if let node = algae.component(ofType: SpriteKitComponent.self)?.node {
					node.position = point + CGPoint.randomAngle * CGFloat.random(in: 50..<200)
					addEntity(algae)
				}
			}
			return
		}
		
		if let biotNode = nodes(at: point).filter({$0.name == Constants.NodeName.biot}).first {
			//print(biotNode.position)
			
			if let selectedEntity = entities.filter({ $0.node == biotNode }).first as? OKEntity,
				let biotComponent = selectedEntity.component(ofType: BiotComponent.self) {
				
				if biotComponent.isInteracting, clickCount == 2 {
					biotComponent.isInteracting = false
					return
				}
				
				if shiftDown, commandDown, gameConfig.gameMode == .random {
					entities(withName: Constants.NodeName.biot)?.forEach({ biotEntity in
						removeEntity(biotEntity)
					})
					
					let worldRadius = Constants.Env.worldRadius

					for _ in 1...gameConfig.minimumBiotCount {
						let distance = CGFloat.random(in: Constants.Env.worldRadius * 0.05...worldRadius * 0.9)
						let position = CGPoint.randomDistance(distance)
						let clonedGenome = Genome(parent: biotComponent.genome)
						let childBiot = BiotComponent.createBiot(genome: clonedGenome, at: position, fountainComponent: RelayComponent(for: mainFountain))
						addEntity(childBiot)
					}
				}
				else if commandDown, let cameraComponent = entity?.component(ofType: CameraComponent.self) {
					if cameraComponent.nodeToTrack == selectedEntity.node {
						stopTrackingEntity()
					}
					else if let entity = biotComponent.entity as? OKEntity {
						trackEntity(entity)
					}
				}
				else if rightMouse {
					biotComponent.kill()
				}
				else if shiftDown {
					if let jsonData = try? biotComponent.genome.encodedToJSON() {
						if let jsonString = String(data: jsonData, encoding: .utf8) {
							print("\(jsonString),")
						}
					}
					biotComponent.mated(otherGenome: biotComponent.genome)
					biotComponent.spawnChildren(selfReplication: true)
					biotComponent.foodEnergy = biotComponent.maximumEnergy
					biotComponent.hydration = biotComponent.maximumHydration
					return
				}
				else if !rightMouse, let biotNode = nodes(at: point).filter({$0.name == Constants.NodeName.biot}).first,
						let selectedEntity = entities.filter({ $0.node == biotNode }).first as? OKEntity,
						let biotComponent = selectedEntity.component(ofType: BiotComponent.self) {
					draggingNode = biotNode
					lastDragPoint = point - biotNode.position
					biotComponent.isInteracting = true
				}
			}
		}
		else if !rightMouse, let waterNode = nodes(at: point).filter({$0.name == Constants.NodeName.water}).first {
			draggingNode = waterNode
			resizing = shiftDown
			lastDragPoint = point - waterNode.position
		}
		else if !rightMouse, let zapperNode = nodes(at: point).filter({$0.name == Constants.NodeName.zapper}).first {
			draggingNode = zapperNode
			resizing = shiftDown
			lastDragPoint = point - zapperNode.position
		}
		else if rightMouse, let waterNode = nodes(at: point).filter({$0.name == Constants.NodeName.water}).first, let selectedEntity = entities.filter({ $0.node == waterNode }).first as? OKEntity {
			waterNode.run(.fadeOut(withDuration: 0.2)) {
				self.removeEntity(selectedEntity)
			}
		}
		else if rightMouse, let algaeNode = nodes(at: point).filter({$0.name == Constants.NodeName.algae}).first, let selectedEntity = entities.filter({ $0.node == algaeNode }).first as? OKEntity, let algaeComponent = selectedEntity.component(ofType: AlgaeComponent.self) {
			algaeComponent.energy = 0
			algaeComponent.bitten()
		}
		else if rightMouse, let zapperNode = nodes(at: point).filter({$0.name == Constants.NodeName.zapper}).first, let selectedEntity = entities.filter({ $0.node == zapperNode }).first as? OKEntity {
			zapperNode.run(.fadeOut(withDuration: 0.2)) {
				self.removeEntity(selectedEntity)
			}
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
		self.backgroundColor = Constants.Colors.grid
		self.entity?.addComponent(WorldComponent())
					
		self.view?.showsFPS = Constants.Env.showSpriteKitStats
		self.view?.showsNodeCount = Constants.Env.showSpriteKitStats
		self.view?.showsDrawCount = Constants.Env.showSpriteKitStats
		self.view?.showsPhysics = self.gameCoordinator?.entity.component(ofType: GlobalDataComponent.self)?.showPhysics ?? false
		self.view?.ignoresSiblingOrder = true
		self.view?.shouldCullNonVisibleNodes = true
		self.view?.preferredFramesPerSecond = 30
		self.physicsWorld.gravity = .zero
	    		    	
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
	    		    	
    	default: break
    	}
    	
	}
	
	// MARK: 🔶 STEP 6B.6
	override func transition(for nextSceneClass: OKScene.Type) -> SKTransition? {
    	
    	// This method is called by the OKScenePresenter to ask the current scene for a transition animation between the outgoing scene and the next scene.
    	//
    	// Here we display transition effects if the next scene is the TitleScene.
    	
    	//guard nextSceneClass is TitleScene.Type else { return nil }
    	
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
