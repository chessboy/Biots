//
//  PlayUI.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/23.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 6C: The user interface overlay for PlayState, PausedState and GameOverState.
//
//  Once you understand how everything works, you may delete this file and replace it with your own UI.

import SwiftUI
import OctopusKit

struct PlayUI: View {
	
	@EnvironmentObject var gameCoordinator: MyGameCoordinator

	private var globalDataComponent: GlobalDataComponent? {
    	gameCoordinator.entity.component(ofType: GlobalDataComponent.self)
	}
	
	private var worldScene: WorldScene? {
		return gameCoordinator.currentScene as? WorldScene
	}
    	
	var body: some View {
		BiotsUI(globalDataComponent: globalDataComponent!, worldScene: worldScene!)
	}
}

struct BiotsUI: View {
	
	@ObservedObject var globalDataComponent: GlobalDataComponent
	var worldScene: WorldScene

	@State var algaeTargetState: CGFloat!

	init(globalDataComponent: GlobalDataComponent, worldScene: WorldScene) {
		self.globalDataComponent = globalDataComponent
		self.worldScene = worldScene

		_algaeTargetState = State(initialValue: globalDataComponent.algaeTarget.cgFloat)
	}
	
	var body: some View {
		
		let algaeTarget = Binding<CGFloat>(
			get: {
				algaeTargetState
			},
			set: {
				algaeTargetState = $0
				globalDataComponent.algaeTarget = Int($0)
				worldScene.setAlgaeTargetsInFountains(globalDataComponent.algaeTarget)
				GameManager.shared.gameConfig.algaeTarget = Int($0)
			}
		)
		
		let gameConfig = GameManager.shared.gameConfig
		
		return VStack {
			Spacer().frame(maxWidth: .infinity)
			HStack {
				
				VStack {
					Slider(value: algaeTarget, in: 0...20000, step: 1000)
					Text("Algae Target: \(Int(algaeTargetState).abbrev)")
						.font(.body)
						.animation(nil)
				}
				.padding()
				.frame(minWidth: 200, idealWidth: 200, maxWidth: 200)
				
				Button("Save", action: {
					
					let saveState = SaveState(name: Constants.Env.filenameSaveStateSave, gameMode: GameMode.normal, algaeTarget: globalDataComponent.algaeTarget, worldBlockCount: gameConfig.worldBlockCount, worldObjects: worldScene.currentWorldObjects, genomes: worldScene.currentGenomes, minimumBiotCount: gameConfig.minimumBiotCount, maximumBiotCount: gameConfig.maximumBiotCount)
					LocalFileManager.shared.saveStateToFile(saveState, filename: Constants.Env.filenameSaveStateSave)
					
				})
					.font(.body)
					.buttonStyle(FatButtonStyle(color: Constants.Colors.water.color))
			}
			.padding(.top, 20)
			.frame(maxWidth: .infinity)
			.background(Color(white: 0).opacity(0.75))
			Spacer(minLength: 80)
		}
		.opacity(globalDataComponent.showHUDPub ? 1 : 0)
		.animation(.easeInOut(duration: globalDataComponent.showHUDPub ? 0.1 : 0.25))
		.transition(.opacity)
		.frame(maxHeight: .infinity)
	}
}

struct PlayUI_Previews: PreviewProvider {
	
	static let gameCoordinator = MyGameCoordinator()
	
	static var previews: some View {
		gameCoordinator.entity.addComponent(GlobalDataComponent())
		
		return PlayUI()
			.environmentObject(gameCoordinator)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.foregroundColor(.red)
			.background(Color(red: 0.1, green: 0.2, blue: 0.2))
			.edgesIgnoringSafeArea(.all)
	}
}
