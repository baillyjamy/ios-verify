// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SynapsVerify",
    products: [
        .library(name: "SynapsVerify", targets: ["SynapsVerify"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SynapsVerify", dependencies: [], path: "verify")
    ]
)
