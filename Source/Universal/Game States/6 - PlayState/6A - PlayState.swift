//
//  PlayableState.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2018/02/10.
//  Copyright © 2019 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 6A: The "gameplay" state for the QuickStart project, represented by the PlayScene (which also displays the content for the PausedState and GameOverState.)

import GameplayKit
import OctopusKit
import SwiftUI

final class PlayState: OKGameState {
	
	init() {
    	
    	// 🔶 STEP 6A.1: Associates a scene and UI with this state.
    	// The PlayScene is also associated with the PausedState and GamerOverState.
    	
    	super.init(associatedSceneClass: WorldScene.self,
    	    	   associatedSwiftUIView: PlayUI())
	}
	
	override func didEnter(from previousState: GKState?) {
    	
    	// 🔶 STEP 6A.2: This method is called when a state begins.
    	//
    	// Here we add a component to the global game coordinator entity (a property of OKGameCoordinator and its subclasses) which is available to all states and all scenes, to demonstrate how to hold data which will persist throughout the game.
    	
    	if  OctopusKit.shared?.gameCoordinator.entity.component(ofType: GlobalDataComponent.self) == nil {
	    	OctopusKit.shared?.gameCoordinator.entity.addComponent(GlobalDataComponent())
    	}
    	
    	// Note that we pass control to the OKGameState superclass AFTER we've added the global component, so that it will be available to the PlayScene when it's presented by the code in the superclass.
		
		//GameManager.shared.gameConfig = GameConfig(gameMode: .random)
		
		if let saveState: SaveState = LocalFileManager.shared.loadDataFile(Constants.Env.filenameSaveStateDebug, treatAsWarning: true) {
			GameManager.shared.gameConfig = GameConfig(saveState: saveState)
			OctopusKit.logForSimInfo.add("loaded save state: \(saveState.description)")
		}
		else if let saveState: SaveState = LocalFileManager.shared.loadDataFile(Constants.Env.filenameSaveStateSave, treatAsWarning: true) {
			GameManager.shared.gameConfig = GameConfig(saveState: saveState)
			OctopusKit.logForSimInfo.add("loaded save state: \(saveState.description)")
		}
		// then try to load the designated initial state
		else if let saveState: SaveState = LocalFileManager.shared.loadDataFile(Constants.Env.filenameSaveStateEvolved) {
			GameManager.shared.gameConfig = GameConfig(saveState: saveState)
			OctopusKit.logForSimInfo.add("loaded save state: \(saveState.description)")
		} else {
			OctopusKit.logForSimErrors.add("could not load a save state")
			GameManager.shared.gameConfig = GameConfig(gameMode: .random)
		}

    	super.didEnter(from: previousState)
	}
	
	@discardableResult override func octopusSceneDidChooseNextGameState(_ scene: OKScene) -> Bool {
    	
    	// 🔶 STEP 6A.3: This method will be called by the PlayScene when the "Cycle Game States" button is tapped.
    	
    	return false
	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    	
    	// 🔶 STEP 6A.4: The OKGameCoordinator's superclass GKStateMachine calls this method to ask if the current state can transition to the requested state.
    	//
    	// The PlayState can lead to either the PausedState or the GameOverState.
    	
    	return false
	}
	
	
	
}

