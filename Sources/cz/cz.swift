/* TODO: Create an interpreter for the assembly of instructions in this framework.
typealias Cursor = (Int, Range<String.Index>)
struct Input: TextOutputStream {
 enum Error: Swift.Error {
  case empty, nearEmpty
 }
 var cursor: Cursor
 mutating func write(_ string: String) {
  
 }
 mutating func parse() {
  // Lex input
  // Assess declarations
  // Import modules
 }
}

struct Inputs: TextOutputStreamable {
 internal init(generator: Generator = .shared, targets: [Input] = []) {
  self.generator = generator
  self.targets = targets
 }
 func write<Target>(to target: inout Target) where Target : TextOutputStream {
  
 }
 var generator: Generator
 var targets: [Input]
}

struct Generator {
 static let shared = Self()
 var declarations: [Declaration: String] = [:]
 
}
  
// Parser
enum Declaration: String { case `import`, create, store }

struct Runtime {
 internal init(inputs: Inputs = Inputs()) {
  self.inputs = inputs
 }
 var inputs: Inputs
}
*/
