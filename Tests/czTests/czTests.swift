import XCTest
@testable import cz

final class czTests: XCTestCase {
 func testFiltering() {
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
}
