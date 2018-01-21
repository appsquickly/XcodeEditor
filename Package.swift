// swift-tools-version:4.0
//
//  Package.swift
//  XcodeEditor
//

import PackageDescription

let package = Package(
    name: "XcodeEditor",
    products: [
        .library(name: "XcodeEditor", targets: ["XcodeEditor"]),
    ],
    targets: [
        .target(
            name: "XcodeEditor",
            dependencies: [],
            path: "Source",
            publicHeadersPath: "Include"
        ),
    ],
    swiftLanguageVersions: [4]
)
