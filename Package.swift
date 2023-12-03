// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "SynapsVerify",
	platforms: [
		.iOS(.v15),
	],
    products: [
        .library(name: "SynapsVerify", targets: ["SynapsVerify"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SynapsVerify", dependencies: [], path: "SynapsVerify")
    ]
)
