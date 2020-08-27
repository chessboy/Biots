//
//  CGRectMath.swift
//  Qlearn
//
//  Created by Robert Silverman on 4/26/20.
//  Copyright © 2020 Rob Silverman. All rights reserved.
//

import Foundation
public extension CGRect {

    /// SwifterSwift: Create a `CGRect` instance with center and size
    /// - Parameters:
    ///   - center: center of the new rect
    ///   - size: size of the new rect
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width/2, y: center.y - size.height/2)
        self.init(origin: origin, size: size)
    }
}
