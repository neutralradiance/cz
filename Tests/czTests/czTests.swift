import XCTest
@testable import cz

 /// Colors represent the combination of three different colors and their amount.
 /// Ideally, colors should represent light or signals that can be filtered
 /// to create this perception of color.
struct Color: DynamicLayer, Equatable, CustomStringConvertible {
 var input: SIMD3<Double> = [0, 0, 0]
 init() {}
 init(with input: SIMD3<Double>) {
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
 @_transparent static var yellow: Self { Self(0.5, 0.5, 0) }
 
 var description: String {
  switch self {
   case .black: return "Black"
   case .white: return "White"
   case .red: return "Red"
   case .green: return "Green"
   case .blue: return "Blue"
   case .grey: return "Grey"
   case .yellow: return "Yellow"
   default: return "Color [\(input[0]), \(input[1]), \(input[2])]"
  }
 }
}

extension Color: Filter {
 @_transparent mutating func filter(_ input: Input) -> Color {
  average(with: input)
 }
}

final class czTests: XCTestCase {
 func testColor() {
  let black: Color = .black
  let white: Color = .white
  // Average
  let grey: Color = black ~ white
  XCTAssertEqual(grey, .grey)
  let red: Color = .red
  let green: Color = .green
  let yellow: Color = red ~ green
  XCTAssertEqual(yellow, .yellow)
 }
 func testState() {
  var x: Bool = true
  var y: Bool = false
  var z: Bool = true
  let state = State(&x, &y, &z)
  x = false
  XCTAssertEqual(state.x, false)
 }
}
