//
//  LinkShareDIContainer.swift
//  App
//
//  Created by 김건우 on 12/16/23.
//

import UIKit

import Core
import Data
import Domain

public final class InviteFamilyDIContainer: BaseDIContainer {
    public typealias ViewController = InviteFamilyViewController
    public typealias UseCase = FamilyViewUseCaseProtocol
    public typealias Repository = FamilyRepositoryProtocol
    public typealias Reactor = InviteFamilyViewReactor
    
    private var globalState: GlobalStateProviderProtocol {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return GlobalStateProvider()
        }
        return appDelegate.globalStateProvider
    }
    
    public func makeViewController() -> InviteFamilyViewController {
        return InviteFamilyViewController(reactor: makeReactor())
    }
    
    public func makeUsecase() -> FamilyViewUseCaseProtocol {
        return InviteFamilyViewUseCase(familyRepository: makeRepository())
    }
    
    public func makeRepository() -> FamilyRepositoryProtocol {
        return FamilyRepository()
    }
    
    public func makeReactor() -> InviteFamilyViewReactor {
        return InviteFamilyViewReactor(usecase: makeUsecase(), provider: globalState)
    }
}
