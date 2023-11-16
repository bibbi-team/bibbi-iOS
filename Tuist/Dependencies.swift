//
//  Dependencies.swift
//  Config
//
//  Created by Kim dohyun on 11/16/23.
//

import ProjectDescription
import ProjectDescriptionHelpers


let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies([
        .alamofire,
        .reactorKit,
        .rxSwift
    ]),
    platforms: [.iOS]
)