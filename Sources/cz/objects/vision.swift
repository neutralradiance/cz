import Atomics


/* TODO: Test differentiatiable protocols

import _Differentiation

struct Perceptron: Differentiable {
 var weight: SIMD2<Float> = .random(in: -1..<1)
 var bias: Float = 0
 
 @differentiable(reverse)
 func callAsFunction(_ input: SIMD2<Float>) -> Float {
  withoutDerivative(at: (weight * input).sum()) + bias
 }
}
*/

