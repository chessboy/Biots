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
    
    @EnvironmentObject var gameCoordinator:  MyGameCoordinator
    
    private var globalDataComponent: GlobalDataComponent? {
        gameCoordinator.entity.component(ofType: GlobalDataComponent.self)
    }
        
    var body: some View {
		EmptyView()
    }
}

// MARK: - Preview

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
