//
//  File.swift
//  Data
//
//  Created by 김건우 on 6/2/24.
//

import Foundation

import Core
import Domain


public protocol FamilyInfoUserDefaultsType: UserDefaultsType {
    typealias Profile = FamilyMemberProfileEntity
    
    func loadFamilyMember(_ memberId: String) -> Profile?
    
    func saveFamilyMembers(_ members: [Profile])
    func loadFamilyMembers() -> [Profile]?
    func deleteFamilyMembers()
    
    func saveFamilyId(_ familyId: String?)
    func loadFamilyId() -> String?
    
    func saveFamilyCreatedAt(_ familyCreatedAt: Date?)
    func loadFamilyCreatedAt() -> Date?
    
    func saveFamilyName(_ familyName: String?)
    func loadFamilyName() -> String?
}


final public class FamilyInfoUserDefaults: FamilyInfoUserDefaultsType {
  
    
    // MARK: - Intializer
    
    public init() { }
    
    // MARK: - FamilyMember
    
    public func loadFamilyMember(_ memberId: String) -> Profile? {
        guard let familyMembers = loadFamilyMembers() else {
            return nil
        }
        
        let member = familyMembers.filter { $0.memberId == memberId }
        return member.first
    }
    
    // MARK: - FamilyMembers
    
    public func saveFamilyMembers(_ members: [Profile]) {
        userDefaults[.familyMembers] = members
    }
    
    public func loadFamilyMembers() -> [Profile]? {
        guard let value: [Profile] = userDefaults[.familyMembers] else {
            return nil
        }
        return value
    }
    
    public func deleteFamilyMembers() {
        remove(forKey: .familyMembers)
    }
    
    
    // MARK: - Family Id
    
    public func saveFamilyId(_ familyId: String?) {
        userDefaults[.familyId] = familyId
    }
    
    public func loadFamilyId() -> String? {
        guard
            let familyId: String? = userDefaults[.familyId]
        else { return nil }
        return familyId
    }
    
    
    // MARK: - Family Created At
    
    public func saveFamilyCreatedAt(_ familyCreatedAt: Date?) {
        userDefaults[.familyCreatedAt] = familyCreatedAt
    }
    
    public func loadFamilyCreatedAt() -> Date? {
        guard
            let familyCreatedAt: Date? = userDefaults[.familyCreatedAt]
        else { return nil }
        return familyCreatedAt
    }
    
    
    // MARK: - Family Name
    
    public func saveFamilyName(_ familyName: String?) {
        userDefaults[.familyName] = familyName
    }
    
    public func loadFamilyName() -> String? {
        guard
            let familyName: String? = userDefaults[.familyName]
        else { return nil }
        return familyName
    }
    
}