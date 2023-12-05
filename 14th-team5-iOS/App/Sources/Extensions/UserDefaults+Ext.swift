//
//  UserDefaults+Ext.swift
//  App
//
//  Created by 마경미 on 05.12.23.
//

import Foundation

extension UserDefaults {
    enum Key: String, CaseIterable {
        case chekcPermission

        var value: String { "\(Bundle.current.bundleIdentifier ?? "").\(self.rawValue.lowercased())" }
    }
}

extension UserDefaults {
    var chekcPermission: Bool {
        get { UserDefaults.standard.bool(forKey: Key.chekcPermission.value) }
        set { UserDefaults.standard.set(newValue, forKey: Key.chekcPermission.value) }
    }
}

extension UserDefaults {
    func clear() {
        Key.allCases
            .map { $0.value }
            .forEach(UserDefaults.standard.removeObject)
    }
}
