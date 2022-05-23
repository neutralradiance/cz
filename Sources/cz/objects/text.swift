import Foundation

struct Text: DynamicLayer {
 init(with input: Never) { fatalError() }
}

extension Text: ExpressibleByStringLiteral {
 init(stringLiteral: String) { fatalError() }
}
