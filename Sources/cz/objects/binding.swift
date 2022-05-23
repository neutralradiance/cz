import Atomics

 /// The binding of perspectives needed to create a compound state or
 /// object that represents three adresses of mutable or immutable memory.
 /// For now, the minimum for any compound state is three perspectives.
protocol Binding: Perspective {
 associatedtype X: Perspective
 associatedtype Y: Perspective
 associatedtype Z: Perspective
 var x: X { get }
 var y: Y { get }
 var z: Z { get }
}

/// A mutable binding
protocol DynamicBinding: Binding {
 override var x: X { get nonmutating set }
 override var y: Y { get nonmutating set }
 override var z: Z { get nonmutating set }
}

protocol AtomicBinding: DynamicBinding {
 var _x: ManagedAtomic<UnsafeMutablePointer<X>> { get }
 var _y: ManagedAtomic<UnsafeMutablePointer<Y>> { get }
 var _z: ManagedAtomic<UnsafeMutablePointer<Z>> { get }
}


extension AtomicBinding {
 @_transparent var xPointer: UnsafeMutablePointer<X> {
  _x.load(ordering: .relaxed)
 }
 @_transparent var yPointer: UnsafeMutablePointer<Y> {
  _y.load(ordering: .relaxed)
 }
 @_transparent var zPointer: UnsafeMutablePointer<Z> {
  _z.load(ordering: .relaxed)
 }

 @_transparent var x: X {
  unsafeAddress { UnsafePointer(xPointer) }
  nonmutating unsafeMutableAddress { xPointer }
 }
 @_transparent var y: Y {
  unsafeAddress { UnsafePointer(yPointer) }
  nonmutating unsafeMutableAddress { yPointer }
 }
 @_transparent var z: Z {
  unsafeAddress { UnsafePointer(zPointer) }
  nonmutating unsafeMutableAddress { zPointer }
 }
}

 /// A `Binding` that connects mulitple perspectives using atomic pointers.
struct State<X, Y, Z>: AtomicBinding
where X: Perspective, Y: Perspective, Z: Perspective {
 let _x: ManagedAtomic<UnsafeMutablePointer<X>>
 let _y: ManagedAtomic<UnsafeMutablePointer<Y>>
 let _z: ManagedAtomic<UnsafeMutablePointer<Z>>
}

extension State {
 init(_ x: inout X, _ y: inout Y, _ z: inout Z) {
  _x = ManagedAtomic(withUnsafeMutablePointer(to: &x) { $0 })
  _y = ManagedAtomic(withUnsafeMutablePointer(to: &y) { $0 })
  _z = ManagedAtomic(withUnsafeMutablePointer(to: &z) { $0 })
 }
}

extension State: CustomStringConvertible {
 var description: String { "State(x: \(x), y: \(y), z: \(z))" }
}
