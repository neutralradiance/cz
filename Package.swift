// swift-tools-version: 5.6

import PackageDescription

let package = Package(
 name: "cz",
 products: [
  .library(
   name: "cz",
   targets: ["cz"]
  )
 ],
 dependencies: [
  .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.2"),
  .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2")
 ],
 targets: [
  .target(
   name: "cz",
   dependencies: [
    .product(name: "Atomics", package: "swift-atomics"),
    .product(name: "Numerics", package: "swift-numerics")
   ]
  ),
  .testTarget(
   name: "czTests",
   dependencies: ["cz"]
  )
 ]
)
