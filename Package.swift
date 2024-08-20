// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "Screens",
  platforms: [
    .macOS(.v14),
    .iOS(.v15),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13)],
  products: [
    .library(
      name: "ScreensUI",
      targets: ["ScreensUI"]
    ),
    .library(
      name: "ScreensBrowser",
      targets: ["ScreensBrowser"]
    ),
    .executable(
        name: "ScreensClient",
        targets: ["ScreensClient"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax", "509.0.0"..<"601.0.0"),
  ],
  targets: [
    .macro(
      name: "ScreensMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ],
      path: "Sources/ScreensMacros"
    ),
    .target(name: "ScreensBrowser",
            path: "Sources/ScreensBrowser"),

    .target(name: "ScreensUI",
            dependencies: ["ScreensBrowser", "ScreensMacros", "Notifications"],
            path: "Sources/Screens"),

    .target(name: "Notifications",
            path: "Sources/Notifications"),

    .executableTarget(name: "ScreensClient",
                      dependencies: ["ScreensUI"],
                      path: "Sources/ScreensClient"),
    .testTarget(
      name: "ScreensTests",
      dependencies: [
        "ScreensMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
