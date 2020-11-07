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
		node.name = Constants.NodeName.grid
		node.zPosition = Constants.ZeeOrder.grid
		let size = CGSize(width: CGFloat(cols)*blockSize, height: CGFloat(rows)*blockSize)
		let path = CGMutablePath()
		
		// x^2 + y^2 = r^2
		// x = sqrt(r*r - y*y)
		// y = sqrt(r*r - x*x)
		
		let r = size.height/2
		
		for i in -cols...cols {
			let x = CGFloat(i) * blockSize
			if r*r - x*x > 0 {
				let y1 = sqrt(r*r - x*x)
				let y2 = -y1
				path.move(to: CGPoint(x: x + r, y: y1 + r))
				path.addLine(to: CGPoint(x: x + r, y: y2 + r))
			}
		}

		for i in -rows...rows {
			let y = CGFloat(i) * blockSize
			if r*r - y*y > 0 {
				let x1 = sqrt(r*r - y*y)
				let x2 = -x1
				path.move(to: CGPoint(x: x1 + r, y: y + r))
				path.addLine(to: CGPoint(x: x2 + r, y: y + r))
			}
		}

		node.lineWidth = 6
		node.strokeColor = Constants.Colors.grid
		node.path = path
		node.position = CGPoint(x: -size.width/2, y: -size.height/2)
		
		return node
	}
}
