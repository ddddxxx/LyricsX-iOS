// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LyricsUI",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "LyricsUI",
            targets: ["LyricsUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ddddxxx/LyricsKit", from: "0.8.3"),
    ],
    targets: [
        .target(
            name: "LyricsUI",
            dependencies: ["LyricsKit"]),
    ]
)

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }
}

extension ProcessInfo {

    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
}

import Foundation

if ProcessInfo.processInfo.combineImplementation == .combine {
    package.platforms = [.macOS(.v10_15), .iOS(.v13)]
}
