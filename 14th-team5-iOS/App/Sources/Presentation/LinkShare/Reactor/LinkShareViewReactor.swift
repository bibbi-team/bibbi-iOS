//
//  LinkShareViewReactor.swift
//  App
//
//  Created by 김건우 on 12/11/23.
//

import Foundation

import Core
import Data
import ReactorKit
import RxSwift

final class LinkShareViewReactor: Reactor {
    // MARK: - Action
    enum Action { 
        case didTapInvitationUrlButton
    }
    
    // MARK: - Mutate
    enum Mutation { 
        case presentSharePanel(URL?)
        case presentToastMessage
    }
    
    // MARK: - State
    struct State { 
        @Pulse var invitationUrl: URL?
        @Pulse var shouldPresentToastMessage: Bool = false
    }
    
    // MARK: - Properties
    let initialState: State
    let linkShareViewRepository: LinkShareViewRepository
    let provider: GlobalStateProviderType
    
    // MARK: - Intializer
    init(provider: GlobalStateProviderType) {
        self.initialState = State()
        self.linkShareViewRepository = LinkShareViewRepository()
        self.provider = provider
    }
    
    // MARK: - Transform
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let eventMutation = provider.activityGlobalState.event
            .flatMap { event -> Observable<Mutation> in
                switch event {
                case .didTapCopyInvitationUrlAction:
                    return Observable<Mutation>.just(.presentToastMessage)
                }
            }
        
        return Observable<Mutation>.merge(mutation, eventMutation)
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapInvitationUrlButton:
            // TODO: - FamilyID 구하는 코드 구현
            return linkShareViewRepository.responseInvitationUrl("familyId")
                .map { .presentSharePanel($0) }
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .presentSharePanel(url):
            newState.invitationUrl = url
        case .presentToastMessage:
            newState.shouldPresentToastMessage = true
        }
        return newState
    }
}