import Foundation

protocol Filter {
 associatedtype I
 associatedtype O
 @discardableResult mutating func filter(_ input: I) -> O
 var _input: UnsafeMutablePointer<I> { get }
}

extension Filter {
 var _input: UnsafeMutablePointer<I> {
  fatalError("Input not set for \(Self.self)")
 }
 var input: I {
  @_transparent unsafeAddress { UnsafePointer(_input) }
  @_transparent nonmutating unsafeMutableAddress { _input }
 }
 func filtering(_ input: I) -> O {
  var `self` = self
  return self.filter(input)
 }
}

