//
//  HomeViewReactor.swift
//  App
//
//  Created by 마경미 on 05.12.23.
//

import UIKit

import Core
import Domain
import DesignSystem

import ReactorKit
import RxDataSources
import Kingfisher


enum Description {
    case survivalNone
    case survivalFull
    case missionNone(Int)
    case mission(String)
    case missionFull
    
    var text: String {
        switch self {
        case .survivalNone:
            return "매일 12-24시에 사진 한 장을 올려요"
        case .survivalFull:
            return "우리 가족 모두가 사진을 올린 날"
        case .missionNone(let count):
            return "가족 중 \(count)명만 더 올리면 미션 열쇠를 받아요!"
        case .mission(let string):
            return string
        case .missionFull:
            return "우리 가족 모두가 미션을 성공한 날"
        }
    }
    
    var image: UIImage {
        switch self {
        case .survivalNone, .mission:
            return DesignSystemAsset.smile.image
        case .missionFull, .survivalFull:
            return DesignSystemAsset.congratulation.image
        case .missionNone:
            return DesignSystemAsset.missionKeyGraphic.image
        }
    }
}

final class MainViewReactor: Reactor {
    
    enum Action {
        case calculateTime
        case fetchMainUseCase
        
        case didTapSegmentControl(PostType)
        case pickConfirmButtonTapped(String, String)
        
        case pushWidgetPostDeepLink(WidgetDeepLink)
        case pushNotificationPostDeepLink(NotificationDeepLink)
        case pushNotificationCommentDeepLink(NotificationDeepLink)
    }
    
    enum Mutation {
        case updateMainData(MainData)
        
        case setInTime(Bool)
        case setPageIndex(Int)
        case setBalloonText
        case setDescriptionText
        
        case setPickSuccessToastMessage(String)
        case setCopySuccessToastMessage
        case setFailureToastMessage
        
        case setPickAlertView(String, String)
        
        case setWidgetPostDeepLink(WidgetDeepLink)
        case setNotificationPostDeepLink(NotificationDeepLink)
        case setNotificationCommentDeepLink(NotificationDeepLink)
    }
    
    struct State {
        var isInTime: Bool
        var pageIndex: Int = 0
        var leftCount: Int = 0
        var missionText: String = ""
        var balloonText: BalloonText = .survivalStandard
        var description: Description = .survivalNone

        var isFamilySurvivalUploadedToday: Bool = false
        var isFamilyMissionUploadedToday: Bool = false
        var isMeSurvivalUploadedToday: Bool = false
        var isMissionUnlocked: Bool = false
        
        @Pulse var familySection: [FamilySection.Item] = []
        
        @Pulse var widgetPostDeepLink: WidgetDeepLink?
        @Pulse var notificationPostDeepLink: NotificationDeepLink?
        @Pulse var notificationCommentDeepLink: NotificationDeepLink?
        
        @Pulse var shouldPresentPickAlert: (String, String)?
        @Pulse var shouldPresentPickSuccessToastMessage: String?
        @Pulse var shouldPresentCopySuccessToastMessage: Bool = false
        @Pulse var shouldPresentFailureToastMessage: Bool = false
    }
    
    let initialState: State
    let fetchMainUseCase: FetchMainUseCaseProtocol
    let pickUseCase: PickUseCaseProtocol
    let provider: GlobalStateProviderProtocol
    
    init(
        initialState: State,
        fetchMainUseCase: FetchMainUseCaseProtocol,
        pickUseCase: PickUseCaseProtocol,
        provider: GlobalStateProviderProtocol
    ) {
        self.initialState = initialState
        self.fetchMainUseCase = fetchMainUseCase
        self.pickUseCase = pickUseCase
        self.provider = provider
    }
}

extension MainViewReactor {
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let homeMutation = provider.homeService.event
            .flatMap { event in
                switch event {
                case let .presentPickAlert(name, id):
                    return Observable<Mutation>.just(.setPickAlertView(name, id))
                default:
                    return Observable<Mutation>.empty()
                }
            }
        
        let eventMutation = provider.activityGlobalState.event
            .flatMap { event -> Observable<Mutation> in
                switch event {
                case .didTapCopyInvitationUrlAction:
                    return Observable<Mutation>.just(.setCopySuccessToastMessage)
                default:
                    return Observable<Mutation>.empty()
                }
            }
        
        return Observable<Mutation>.merge(mutation, eventMutation, homeMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMainUseCase:
            return fetchMainUseCase.execute()
                .flatMap { result -> Observable<MainViewReactor.Mutation> in
                    guard let data = result else {
                        return Observable.empty()
                    }
                    return Observable.concat(Observable.just(.updateMainData(data)), Observable.just(.setBalloonText))
                }
        case .calculateTime:
            let (_, time) = MainViewReactor.calculateRemainingTime()
            
            if self.currentState.isInTime {
                return Observable<Int>
                    .timer(.seconds(time), scheduler: MainScheduler.instance)
                    .flatMap {_ in
                        return Observable.concat([Observable.just(Mutation.setInTime(false))])
                    }
            } else {
                return Observable<Int>
                    .timer(.seconds(time), scheduler: MainScheduler.instance)
                    .flatMap {_ in
                        return Observable.concat([Observable.just(Mutation.setInTime(true))])
                    }
                
            }
        case let .pushWidgetPostDeepLink(deepLink):
            return Observable.concat(
                Observable<Mutation>.just(.setWidgetPostDeepLink(deepLink)) // 다음 화면으로 이동하기
            )
            
        case let .pushNotificationPostDeepLink(deepLink):
            return Observable.concat(
                Observable<Mutation>.just(.setNotificationPostDeepLink(deepLink)) // 다음 화면으로 이동하기
            )
            
        case let .pushNotificationCommentDeepLink(deepLink):
            return Observable.concat(
                Observable<Mutation>.just(.setNotificationCommentDeepLink(deepLink)) // 다음 화면으로 이동하기
            )
        case .didTapSegmentControl(let type):
            return Observable.concat(
                Observable.just(.setPageIndex(type.getIndex())),
                Observable.just(.setBalloonText),
                Observable.just(.setDescriptionText))
                
            
        case let .pickConfirmButtonTapped(name, id):
            return pickUseCase.executePickMember(memberId: id)
                .flatMap { response in
                    guard let response = response,
                          response.success else {
                        return Observable<Mutation>.just(.setFailureToastMessage)
                    }
                    self.provider.homeService.showPickButton(false, memberId: id)
                    return Observable<Mutation>.just(.setPickSuccessToastMessage(name))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setInTime(let isInTime):
            newState.isInTime = isInTime
        case let.setWidgetPostDeepLink(deepLink):
            newState.widgetPostDeepLink = deepLink
        case let .setNotificationPostDeepLink(deepLink):
            newState.notificationPostDeepLink = deepLink
        case let .setNotificationCommentDeepLink(deepLink):
            newState.notificationCommentDeepLink = deepLink
        case .setCopySuccessToastMessage:
            newState.shouldPresentCopySuccessToastMessage = true
        case let .setPickSuccessToastMessage(name):
            newState.shouldPresentPickSuccessToastMessage = name
        case .setFailureToastMessage:
            newState.shouldPresentFailureToastMessage = true
        case .setPageIndex(let index):
            newState.pageIndex = index
        case .updateMainData(let data):
            newState.isMissionUnlocked = data.isMissionUnlocked
            newState.isMeSurvivalUploadedToday = data.isMeSurvivalUploadedToday
            newState.isFamilyMissionUploadedToday = data.isFamilyMissionUploadedToday
            newState.isFamilySurvivalUploadedToday = data.isFamilySurvivalUploadedToday
            newState.leftCount = data.leftUploadCountUntilMissionUnlock
            newState.missionText = data.dailyMissionContent
            newState.familySection = FamilySection.Model(
                model: 0,
                items: data.mainFamilyProfileDatas.map {
                    .main(MainFamilyCellReactor($0, service: provider))
                }
            ).items
        case let .setPickAlertView(name, id):
            newState.shouldPresentPickAlert = (name, id)
        case .setBalloonText:
            if currentState.pageIndex == 0 {
                newState.balloonText = .survivalStandard
            } else {
                if currentState.isMissionUnlocked {
                    newState.balloonText = .cantMission
                } else {
                    newState.balloonText = .canMission
                }
            }
        case .setDescriptionText:
            if currentState.pageIndex == 0 {
                if currentState.isFamilySurvivalUploadedToday {
                    newState.description = .survivalFull
                } else {
                    newState.description = .survivalNone
                }
            } else {
                if currentState.isMissionUnlocked {
                    newState.description = .missionNone(currentState.leftCount)
                } else {
                    if currentState.isFamilyMissionUploadedToday {
                        newState.description = .missionFull
                    } else {
                        newState.description = .mission(currentState.missionText)
                    }
                }
            }
        }
        
        return newState
    }
}

extension MainViewReactor {
    private static func calculateRemainingTime() -> (Bool, Int) {
        let calendar = Calendar.current
        let currentTime = Date()
        
        let currentHour = calendar.component(.hour, from: currentTime)
        
        if currentHour >= 12 {
            if let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentTime.addingTimeInterval(24 * 60 * 60)) {
                let timeDifference = calendar.dateComponents([.second], from: currentTime, to: nextMidnight)
                return (true, max(0, timeDifference.second ?? 0))
            }
        } else {
            if let nextMidnight = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: currentTime) {
                let timeDifference = calendar.dateComponents([.second], from: currentTime, to: nextMidnight)
                return (false, max(0, timeDifference.second ?? 0))
            }
        }
        
        return (false, 0)
    }
    
}