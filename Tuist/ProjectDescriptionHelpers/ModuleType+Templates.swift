//
//  ModuleType+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim dohyun on 2023/11/14.
//

import ProjectDescription

public protocol ModuleType {
    var dependencies: [TargetDependency] { get }
}

public enum ExtensionsLayer: String, ModuleType {
    case Widget
    
    public var dependencies: [TargetDependency] {
        switch self {
        case .Widget:
            return [
                .with(.Core),
                .with(.Domain)
            ]
        }
    }
    
}

public enum ModuleLayer: String, CaseIterable, ModuleType {
    
    case App
    case Data
    case Domain
    case Core
    case DesignSystem
    
    
    public var dependencies: [TargetDependency] {
        switch self {
        case .App:
            return [
                .target(name: "WidgetExtension"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseMessaging"),
                .with(.Core),
                .with(.Data),
                .external(name: "ReactorKit")
            ]
        case .Data:
            return [
                .with(.Core),
                .with(.Domain),
                .external(name: "Alamofire"),
                .external(name: "RxSwift"),
                .external(name: "KakaoSDK"),
                .external(name: "RxKakaoSDK"),
            ]
        case .Domain:
            return [
                .external(name: "RxSwift"),
                .with(.Core)
            ]
        case .Core:
            return [
                .with(.DesignSystem),
                .external(name: "Mixpanel"),
                .external(name: "RxDataSources"),
                .external(name: "SnapKit"),
                .external(name: "Then"),
                .external(name: "KakaoSDK"),
                .external(name: "RxKakaoSDK"),
                .external(name: "Kingfisher"),
                .external(name: "FSCalendar"),
                .external(name: "SwiftKeychainWrapper")
            ]
        case .DesignSystem:
            return [] 
        }
    }
    
}
