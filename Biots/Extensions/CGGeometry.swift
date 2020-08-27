// https://gist.github.com/detomon/864a6b7c51f8bed7a022#file-cggeometry-swift-L239

import Foundation

/**
 * CGPoint
 *
 * var a = CGPointMake(13.5, -34.2)
 * var b = CGPointMake(8.9, 22.4)
 * ...
 */

/**
 * ...
 * a * 10.4
 */
func * (left: CGPoint, right: CGFloat) -> CGPoint {
	return CGPoint(x: left.x * right, y: left.y * right)
}

/**
 * ...
 * a *= 10.4
 */
func *= (left: inout CGPoint, right: CGFloat) {
	left = left * right
}

/**
 * ...
 * a / 10.4
 */
func / (left: CGPoint, right: CGFloat) -> CGPoint {
	return CGPoint(x: left.x / right, y: left.y / right)
}

/**
 * ...
 * a /= 10.4
 */
func /= (left: inout CGPoint, right: CGFloat) {
	left = left / right
}

/**
 * var c = CGSizeMake(20.4, 75.8)
 * ...
 */

/**
 * ...
 * a + c
 */
func + (left: CGPoint, right: CGSize) -> CGPoint {
	return CGPoint(x: left.x + right.width, y: left.y + right.height)
}

/**
 * ...
 * a += c
 */
func += (left: inout CGPoint, right: CGSize) {
	left = left + right
}

/**
 * ...
 * a - c
 */
func - (left: CGPoint, right: CGSize) -> CGPoint {
	return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

/**
 * ...
 * a -= c
 */
func -= (left: inout CGPoint, right: CGSize) {
	left = left - right
}

/**
 * ...
 * a * c
 */
func * (left: CGPoint, right: CGSize) -> CGPoint {
	return CGPoint(x: left.x * right.width, y: left.y * right.height)
}

/**
 * ...
 * a *= c
 */
func *= (left: inout CGPoint, right: CGSize) {
	left = left * right
}

/**
 * ...
 * a / c
 */
func / (left: CGPoint, right: CGSize) -> CGPoint {
	return CGPoint(x: left.x / right.width, y: left.y / right.height)
}

/**
 * ...
 * a /= c
 */
func /= (left: inout CGPoint, right: CGSize) {
	left = left / right
}

/**
 * ...
 * -a
 */
prefix func - (left: CGPoint) -> CGPoint {
	return CGPoint(x: -left.x, y: -left.y)
}


/**
* Adds a CGVector to this CGPoint and returns the result as a new CGPoint.
*/
public func + (left: CGPoint, right: CGVector) -> CGPoint {
	return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

/**
* Increments a CGPoint with the value of a CGVector.
*/
public func += (left: inout CGPoint, right: CGVector) {
	left = left + right
}

/**
* Subtracts a CGVector from a CGPoint and returns the result as a new CGPoint.
*/
public func - (left: CGPoint, right: CGVector) -> CGPoint {
	return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

/**
* Decrements a CGPoint with the value of a CGVector.
*/
public func -= (left: inout CGPoint, right: CGVector) {
	left = left - right
}

/**
* Multiplies a CGPoint with a CGVector and returns the result as a new CGPoint.
*/
public func * (left: CGPoint, right: CGVector) -> CGPoint {
	return CGPoint(x: left.x * right.dx, y: left.y * right.dy)
}

/**
* Multiplies a CGPoint with a CGVector.
*/
public func *= (left: inout CGPoint, right: CGVector) {
	left = left * right
}

/**
* Divides a CGPoint by a CGVector and returns the result as a new CGPoint.
*/
public func / (left: CGPoint, right: CGVector) -> CGPoint {
	return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
}

/**
* Divides a CGPoint by a CGVector.
*/
public func /= (left: inout CGPoint, right: CGVector) {
	left = left / right
}

extension CGPoint {
	/**
	 * Get point by rounding to nearest integer value
	 */
	var integerPoint: CGPoint {
		return CGPoint(
			x: CGFloat(Int(self.x >= 0.0 ? self.x + 0.5 : self.x - 0.5)),
			y: CGFloat(Int(self.y >= 0.0 ? self.y + 0.5 : self.y - 0.5))
		)
	}
}

/**
 * Get minimum x and y values of multiple points
 */
func min(a: CGPoint, b: CGPoint, rest: CGPoint...) -> CGPoint {
	var p = CGPoint(x: min(a.x, b.x), y: min(a.y, b.y))

	for point in rest {
		p.x = min(p.x, point.x)
		p.y = min(p.y, point.y)
	}

	return p
}

/**
 * Get maximum x and y values of multiple points
 */
func max(a: CGPoint, b: CGPoint, rest: CGPoint...) -> CGPoint {
	var p = CGPoint(x: max(a.x, b.x), y: max(a.y, b.y))

	for point in rest {
		p.x = max(p.x, point.x)
		p.y = max(p.y, point.y)
	}

	return p
}

/**
 * CGSize
 */

/**
 * var a = CGSizeMake(8.9, 14.5)
 * var b = CGSizeMake(20.4, 75.8)
 * ...
 */

/**
 * ...
 * a + b
 */
func + (left: CGSize, right: CGSize) -> CGSize {
	return CGSize(width: left.width + right.width, height: left.height + right.height)
}

/**
 * ...
 * a += b
 */
func += (left: inout CGSize, right: CGSize) {
	left = left + right
}

/**
 * ...
 * a - b
 */
func - (left: CGSize, right: CGSize) -> CGSize {
	return CGSize(width: left.width - right.width, height: left.height - right.height)
}

/**
 * ...
 * a -= b
 */
func -= (left: inout CGSize, right: CGSize) {
	left = left - right
}

/**
 * ...
 * a * b
 */
func * (left: CGSize, right: CGSize) -> CGSize {
	return CGSize(width: left.width * right.width, height: left.height * right.height)
}

/**
 * ...
 * a *= b
 */
func *= (left: inout CGSize, right: CGSize) {
	left = left * right
}

/**
 * ...
 * a / b
 */
func / (left: CGSize, right: CGSize) -> CGSize {
	return CGSize(width: left.width / right.width, height: left.height / right.height)
}

/**
 * ...
 * a /= b
 */
func /= (left: inout CGSize, right: CGSize) {
	left = left / right
}

/**
 * var c = CGPointMake(-3.5, -17.6)
 * ...
 */

/**
 * ...
 * a + c
 */
func + (left: CGSize, right: CGPoint) -> CGSize {
	return CGSize(width: left.width + right.x, height: left.height + right.y)
}

/**
 * ...
 * a += c
 */
func += (left: inout CGSize, right: CGPoint) {
	left = left + right
}

/**
 * ...
 * a - c
 */
func - (left: CGSize, right: CGPoint) -> CGSize {
	return CGSize(width: left.width - right.x, height: left.height - right.y)
}

/**
 * ...
 * a -= c
 */
func -= (left: inout CGSize, right: CGPoint) {
	left = left - right
}

/**
 * ...
 * a * c
 */
func * (left: CGSize, right: CGPoint) -> CGSize {
	return CGSize(width: left.width * right.x, height: left.height * right.y)
}

/**
 * ...
 * a *= c
 */
func *= (left: inout CGSize, right: CGPoint) {
	left = left * right
}

/**
 * ...
 * a / c
 */
func / (left: CGSize, right: CGPoint) -> CGSize {
	return CGSize(width: left.width / right.x, height: left.height / right.y)
}

/**
 * ...
 * a /= c
 */
func /= (left: inout CGSize, right: CGPoint) {
	left = left / right
}

/**
 * ...
 * a * 4.6
 */
func * (left: CGSize, right: CGFloat) -> CGSize {
	return CGSize(width: left.width * right, height: left.height * right)
}

/**
 * ...
 * a *= 4.6
 */
func *= (left: inout CGSize, right: CGFloat) {
	left = left * right
}

/**
 * CGRect
 *
 * var a = CGRectMake(30.4, 58.6, 20.3, 78.3)
 * var b = CGPointMake(-16.7, 40.5)
 * ...
 */

/**
 * ...
 * a + b
 */
func + (left: CGRect, right: CGPoint) -> CGRect {
	return CGRect(x: left.origin.x + right.x, y: left.origin.y + right.y, width: left.size.width, height: left.size.height)
}

/**
 * ...
 * a += b
 */
func += (left: inout CGRect, right: CGPoint) {
	left = left + right
}

/**
 * ...
 * a - b
 */
func - (left: CGRect, right: CGPoint) -> CGRect {
	return CGRect(x: left.origin.x - right.x, y: left.origin.y - right.y, width: left.size.width, height: left.size.height)
}

/**
 * ...
 * a -= b
 */
func -= (left: inout CGRect, right: CGPoint) {
	left = left - right
}

/**
 * ...
 * a * 2.5
 */
func * (left: CGRect, right: CGFloat) -> CGRect {
	return CGRect(x: left.origin.x * right, y: left.origin.y * right, width: left.size.width * right, height: left.size.height * right)
}

/**
 * ...
 * a *= 2.5
 */
func *= (left: inout CGRect, right: CGFloat) {
	left = left * right
}

/**
 * ...
 * a / 4.0
 */
func / (left: CGRect, right: CGFloat) -> CGRect {
	return CGRect(x: left.origin.x / right, y: left.origin.y / right, width: left.size.width / right, height: left.size.height / right)
}

/**
 * ...
 * a /= 4.0
 */
func /= (left: inout CGRect, right: CGFloat) {
	left = left / right
}

extension CGRect {
	/**
	 * Extend CGRect by CGPoint
	 */
	mutating func union(withPoint: CGPoint) {
		if withPoint.x < self.origin.x { self.size.width += self.origin.x - withPoint.x; self.origin.x = withPoint.x }
		if withPoint.y < self.origin.y { self.size.height += self.origin.y - withPoint.y; self.origin.y = withPoint.y }
		if withPoint.x > self.origin.x + self.size.width { self.size.width = withPoint.x - self.origin.x }
		if withPoint.y > self.origin.y + self.size.height { self.size.height = withPoint.y - self.origin.y; }
	}

	/**
	 * Get end point of CGRect
	 */
	func maxPoint() -> CGPoint {
		return CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height)
	}
}
