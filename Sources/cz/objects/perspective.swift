@dynamicMemberLookup
protocol Perspective {
 associatedtype Input
 var input: Input { get set }
 init(input: Input)
 init()
}

extension Perspective where Input == Never {
 var input: Never { get { fatalError() } set {} }
}

extension Perspective {
 subscript<A>(dynamicMember keyPath: WritableKeyPath<Self, A>) -> A {
  get { self[keyPath: keyPath] }
  mutating set { self[keyPath: keyPath] = newValue }
 }
}
