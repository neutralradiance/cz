import Foundation
import Numerics

/// Colors represent the combination of three different colors and their amount.
/// Ideally, colors should represent light or signals that can be filtered
/// to create this perception of color.
struct Color: Perspective, Equatable, CustomStringConvertible {
 var input: SIMD3<Double> = [0, 0, 0]
 init() {}
 init(input: SIMD3<Double>) {
  self.input = input
 }

 internal init(_ red: Double, _ green: Double, _ blue: Double) {
  input = [red, green, blue]
 }

 @_transparent static var black: Self { Self() }
 @_transparent static var white: Self { Self(1, 1, 1) }
 @_transparent static var red: Self { Self(1, 0, 0) }
 @_transparent static var green: Self { Self(0, 1, 0) }
 @_transparent static var blue: Self { Self(0, 0, 1) }
 @_transparent static var grey: Self { Self(0.5, 0.5, 0.5) }

 var description: String {
  switch self {
   case .black: return "Black"
   case .white: return "White"
   case .red: return "Red"
   case .green: return "Green"
   case .blue: return "Blue"
   case .grey: return "Grey"
   default: return "Color [\(input[0]), \(input[1]), \(input[2])]"
  }
 }
}

extension Color: Filter {
 @_transparent mutating func filter(_ input: Self) -> Self { average(input) }
}

// MARK: SIMD Filters
struct Average<I: Perspective, O: Perspective>: Filter
 where I.Input: SIMD, I.Input.Scalar: Real, O.Input == I.Input {
 let _input: UnsafeMutablePointer<I>

 init(_ input: inout I) { _input = withUnsafeMutablePointer(to: &input) { $0 } }

 @discardableResult
 @_transparent func filter(_ input: I) -> O {
  self.input = I(input: (input.input + self.input.input) / 2)
  return O(input: self.input.input)
 }
}

infix operator ~: MultiplicationPrecedence
extension Perspective where Input: SIMD, Input.Scalar: Real {
 @discardableResult
 @_transparent mutating func average(_ rhs: Self) -> Self {
  input = (input + rhs.input) / 2
  return self
 }

 @_transparent func averaged(_ rhs: Self) -> Self {
  var `self` = self
  return self.average(rhs)
 }

 @_transparent static func ~ (lhs: Self, rhs: Self) -> Self {
  lhs.averaged(rhs)
 }
}

// MARK: Array SIMD Functions
extension Array
 where
 Element: Perspective & Filter,
 Element.Input: SIMD, Element.Input.Scalar: Real,
 Element.I == Element, Element.O == Element {
 mutating func makeGradient() {
  guard count > 2 else {
   guard count == 2 else { return }
   // Insert filtered element in between the two elements
   insert(self[0].filtering(self[1]), at: 1)
   return
  }
  // Insert duplicate of middle element if count is odd
  if !count.isMultiple(of: 2) {
   let mid = (count / 2)
   insert(self[mid], at: mid)
  }
  // Clamp range to bounds of first and before last
  let range = indices.clamped(to: startIndex ..< endIndex - 1)
  replaceSubrange(
   range.dropFirst(),
   with: range.map { self[$0].filtering(self[index(after: $0)]) }
  )
 }

 func gradient() -> Self {
  var `self` = self
  self.makeGradient()
  return self
 }

 func filtered() -> Element {
  var input: Element.Input = .init()
  for element in self {
   input += element.input
  }
  return Element(input: input / Element.Input.Scalar(count))
 }

 func gradientFiltered() -> Element { reduce(into: self[0]) { $0.filter($1) } }

 // Transforms
 mutating func scale(by min: Int) {
  guard min > 1 else { return }
  self = flatMap { Self(repeating: $0, count: min) }
 }

 func scaled(by min: Int) -> Self {
  var `self` = self
  self.scale(by: min)
  return self
 }
}
