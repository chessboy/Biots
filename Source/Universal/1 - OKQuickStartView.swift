//
//  OKQuickStartView.swift
//  OctopusKitQuickStart
//
//  Created by ShinryakuTako@invadingoctopus.io on 2019/10/16.
//  Copyright © 2020 Invading Octopus. Licensed under Apache License v2.0 (see LICENSE.txt)
//

//  🔶 STEP 1: A SwiftUI view which displays the OctopusKit QuickStart "game".
//
//  Add this view in the `body` property of your SwiftUI project's `ContentView.swift` file.

import SwiftUI
import OctopusKit
import Combine

typealias OctopusKitQuickStartView = OKQuickStartView // In case you prefer the longer prefix :)

struct OKQuickStartView: View {
	
	var body: some View {
    	
    	return OKContainerView<MyGameCoordinator, MyGameViewController>()
	    	.environmentObject(MyGameCoordinator())
			.edgesIgnoringSafeArea(.all)
	}
}

struct OKQuickStartView_Previews: PreviewProvider {
	static var previews: some View {
    	Text("See the TitleUI preview.")
	}
}
