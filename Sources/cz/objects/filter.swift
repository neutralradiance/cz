import Atomics
import Numerics

/// A perspective that reads an input then produces an output.
protocol Filter: Layer {
 associatedtype Output
 @discardableResult mutating func filter(_ input: Input) -> Output
}

protocol DynamicFilter: Filter, DynamicLayer {}

protocol AtomicFilter: DynamicFilter {
 var _input: ManagedAtomic<UnsafeMutablePointer<Input>> { get }
}

extension AtomicFilter {
 @_transparent var inputPointer: UnsafeMutablePointer<Input> {
  _input.load(ordering: .relaxed)
 }
 var input: Input {
  @_transparent unsafeAddress { UnsafePointer(inputPointer) }
  @_transparent nonmutating unsafeMutableAddress { inputPointer }
 }
}

extension Filter {
 func filtering(_ input: Input) -> Output {
  var `self` = self
  return self.filter(input)
 }
}

 // MARK: SIMD Filters
infix operator ~: MultiplicationPrecedence

extension DynamicLayer where Input: SIMD, Input.Scalar: Real {
 @discardableResult
 @_transparent mutating func average(with input: Input) -> Self {
  self.input = (self.input + input) / 2
  return self
 }
 
 @_transparent func averaged(_ rhs: Self) -> Self {
  var `self` = self
  return self.average(with: rhs.input)
 }
 
 @_transparent static func ~ (lhs: Self, rhs: Self) -> Self {
  lhs.averaged(rhs)
 }
}

 // MARK: Array SIMD Functions
extension Array
where
Element: Layer & Filter,
Element.Input: SIMD, Element.Input.Scalar: Real,
Element.Input == Element, Element.Output == Element {
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
  return Element(with: input / Element.Input.Scalar(count))
 }
 
 func gradientFiltered() -> Element { reduce(into: self[0]) { $0.filter($1) } }
 
  // MARK: Array SIMD Transformations -
 
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
