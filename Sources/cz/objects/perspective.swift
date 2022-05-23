protocol Perspective {}

/// A perspective that reads an input.
@dynamicMemberLookup
protocol Layer: Perspective {
 associatedtype Input
 var input: Input { get }
 init(with input: Input)
}

protocol DynamicLayer: Layer {
 override var input: Input { get set }
}

extension Layer where Input == Never {
 var input: Never { get { fatalError() } set {} }
 init(with input: Never) { fatalError() }
}

extension Layer {
 subscript<A>(dynamicMember keyPath: WritableKeyPath<Self, A>) -> A {
  get { self[keyPath: keyPath] }
  mutating set { self[keyPath: keyPath] = newValue }
 }
 
 @_transparent mutating func mutating(with transform: (inout Self) -> ()) {
  transform(&self)
 }
 
 @_transparent func copying(with transform: (inout Self) -> ()) -> Self {
  var `self` = self
  transform(&self)
  return self
 }
}

// MARK: Standard Conformances

extension Float: Perspective {}
extension Bool: Perspective {}

// MARK: Protocol Conformances

extension Layer where Input: Decodable {
 init(from decoder: Decoder) throws {
  var container = try decoder.unkeyedContainer()
  self.init(with: try container.decode(Input.self))
 }
}

extension Layer where Input: Encodable {
 func encode(to encoder: Encoder) throws {
  var container = encoder.unkeyedContainer()
  try container.encode(input)
 }
}

// MARK: Builder

@resultBuilder
enum Constructor {
 static func buildBlock<A>(_ perspective: A) -> A { perspective }
}
