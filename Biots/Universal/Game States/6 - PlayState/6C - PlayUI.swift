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
	
	var body: some View {
		VStack {
			Spacer().frame(maxWidth: .infinity)
			Button("Select Most Fit (a)", action: { worldScene.selectMostFit() })
				.font(.title)
				.buttonStyle(FatButtonStyle(color: Constants.Colors.water.color))
			Spacer(minLength: 80)
		}
		.opacity(globalDataComponent.showUi ? 1 : 0)
		.animation(.easeInOut(duration: globalDataComponent.showUi ? 0.1 : 0.25))
		.transition(.opacity)
		.frame(maxHeight: .infinity)
	}
}
