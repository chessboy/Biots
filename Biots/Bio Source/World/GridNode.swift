//
//  GridNode.swift
//  Biots
//
//  Created by Robert Silverman on 9/5/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation
import SpriteKit

class GridNode: SKNode {
	
	static func create(blockSize: CGFloat, rows: Int, cols: Int) -> SKNode {
		
		let node = SKShapeNode()
		node.name = "grid"
		node.zPosition = Constants.ZeeOrder.grid
		let size = CGSize(width: CGFloat(cols)*blockSize, height: CGFloat(rows)*blockSize)
		let path = CGMutablePath()

		for i in 0...cols {
			let x = CGFloat(i) * blockSize
			path.move(to: CGPoint(x: x, y: 0))
			path.addLine(to: CGPoint(x: x, y: size.height))
		}

		for i in 0...rows {
			let y = CGFloat(i) * blockSize
			path.move(to: CGPoint(x: 0, y: y))
			path.addLine(to: CGPoint(x: size.width, y: y))
		}
		
		node.lineWidth = 6
		node.strokeColor = Constants.Colors.grid
		node.path = path
		node.position = CGPoint(x: -size.width/2, y: -size.height/2)
		
		return node
	}
}
