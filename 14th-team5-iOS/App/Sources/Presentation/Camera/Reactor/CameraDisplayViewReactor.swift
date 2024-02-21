//
//  CameraDisplayViewReactor.swift
//  App
//
//  Created by Kim dohyun on 12/11/23.
//

import Foundation

import Data
import Domain
import ReactorKit
import Core

public final class CameraDisplayViewReactor: Reactor {

    public var initialState: State
    private var cameraDisplayUseCase: CameraDisplayViewUseCaseProtocol
    
    public enum Action {
        case viewDidLoad
        case didTapArchiveButton
        case fetchDisplayImage(String)
        case didTapConfirmButton
        case hideDisplayEditCell
    }
    
    public enum Mutation {
        case setLoading(Bool)
        case setError(Bool)
        case setDisplayEditSection([DisplayEditItemModel])
        case setRenderImage(Data)
        case saveDeviceimage(Data)
        case setDescription(String)
        case setDisplayEntity(CameraDisplayImageResponse?)
        case setDisplayOriginalEntity(Bool)
        case setPostEntity(CameraDisplayPostResponse?)
    }
    
    public struct State {
        var isLoading: Bool
        var displayDescrption: String
        @Pulse var isError: Bool
        @Pulse var displayData: Data
        @Pulse var displaySection: [DisplayEditSectionModel]
        @Pulse var displayEntity: CameraDisplayImageResponse?
        @Pulse var displayOringalEntity: Bool
        @Pulse var displayPostEntity: CameraDisplayPostResponse?
    }
    
    
    
    init(cameraDisplayUseCase: CameraDisplayViewUseCaseProtocol, displayData: Data) {
        self.cameraDisplayUseCase = cameraDisplayUseCase
        self.initialState = State(
            isLoading: true,
            displayDescrption: "",
            isError: false,
            displayData: displayData,
            displaySection: [.displayKeyword([])],
            displayEntity: nil,
            displayOringalEntity: false,
            displayPostEntity: nil
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let fileName = "\(self.currentState.displayData.hashValue).jpg"
            let parameters: CameraDisplayImageParameters = CameraDisplayImageParameters(imageName: "\(fileName)")
            
            // 요기서 무한 로딩이 걸린다.
            // No Such Key Value 오류는 self.currentState.displayData.jpg 값이 executeDisplayImageURL 에 보낸 값이랑 달라서 오류가 발생함
            
            
            // 흰 화면이 뜨는 거는
            // Presigned URL 쿼리 파람 즉 executeDisplayImageURL에 entity.imageUrl 과
            // executeCombineWithTextImage 에 요청 보낸 image URL이 다르면 흰색 이미지가 뜸
            
            
            return .concat(
                .just(.setLoading(false)),
                .just(.setError(false)),
                .just(.setRenderImage(self.currentState.displayData)),
                cameraDisplayUseCase.executeDisplayImageURL(parameters: parameters)
                    .withUnretained(self)
                    .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
                    .asObservable()
                    .flatMap { owner, entity -> Observable<CameraDisplayViewReactor.Mutation> in
                        guard let originalURL = entity?.imageURL else { 
                            return .concat(
                                .just(.setLoading(true)),
                                .just(.setError(true))
                            )
                        }
                        return owner.cameraDisplayUseCase.executeUploadToS3(toURL: originalURL, imageData: owner.currentState.displayData)
                            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
                            .asObservable()
                            .flatMap { isSuccess -> Observable<CameraDisplayViewReactor.Mutation> in
                                if isSuccess {
                                    return .concat(
                                        .just(.setDisplayEntity(entity)),
                                        .just(.setDisplayOriginalEntity(isSuccess)),
                                        .just(.setLoading(true)),
                                        .just(.setError(false))
                                    )
                                } else {
                                    return .concat(
                                        .just(.setLoading(true)),
                                        .just(.setError(true))
                                    )
                                }
                            }
                    }
            )
        case let .fetchDisplayImage(description):
            return .concat(
                cameraDisplayUseCase.executeDescrptionItems(with: description)
                    .asObservable()
                    .flatMap { items -> Observable<CameraDisplayViewReactor.Mutation> in
                        var sectionItem: [DisplayEditItemModel] = []
                        items.forEach {
                            sectionItem.append(.fetchDisplayItem(DisplayEditCellReactor(title: $0, radius: 8, font: .head1)))
                        }
                        
                        return Observable.concat(
                            .just(.setDisplayEditSection(sectionItem)),
                            .just(.setDescription(description))
                        )
                    }
            )
        case .didTapArchiveButton:
            return .concat(
                .just(.setLoading(false)),
                .just(.saveDeviceimage(self.currentState.displayData)),
                .just(.setLoading(true))
            )
            
        case .didTapConfirmButton:
            
            MPEvent.Camera.uploadPhoto.track(with: nil)
            // 요기서 달라질수 있는지 확인
            // 즉 Server 에서 넘겨준 Entity가

            guard let presingedURL = self.currentState.displayEntity?.imageURL else { return .just(.setError(true)) }
            let originURL = configureOriginalS3URL(url: presingedURL, with: .feed)
            
            let parameters: CameraDisplayPostParameters = CameraDisplayPostParameters(
                imageUrl: originURL,
                content: self.currentState.displayDescrption,
                uploadTime: DateFormatter.yyyyMMddTHHmmssXXX.string(from: Date())
            )
            
            return cameraDisplayUseCase.executeCombineWithTextImage(parameters: parameters)
                .asObservable()
                .flatMap { entity -> Observable<CameraDisplayViewReactor.Mutation> in
                    return .concat(
                        .just(.setLoading(false)),
                        .just(.setPostEntity(entity)),
                        .just(.setLoading(true)),
                        .just(.setError(false))
                    )
                    
                }
        case .hideDisplayEditCell:
            return .concat(
                .just(.setDescription("")),
                .just(.setDisplayEditSection([]))
            )
        }
    }
    
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setRenderImage(originalData):
            newState.displayData = originalData
        case let .saveDeviceimage(saveData):
            newState.displayData = saveData
        case let .setDisplayEditSection(section):
            let sectionIndex = getSection(.displayKeyword([]))
            newState.displaySection[sectionIndex] = .displayKeyword(section)
        case let .setDescription(descrption):
            newState.displayDescrption = descrption
        case let .setDisplayEntity(entity):
            newState.displayEntity = entity
        case let .setDisplayOriginalEntity(entity):
            newState.displayOringalEntity = entity
        case let .setPostEntity(entity):
            newState.displayPostEntity = entity
        case let .setError(isError):
            newState.isError = isError
        }
        return newState
    }
    
    
}

extension CameraDisplayViewReactor {
    
    func getSection(_ section: DisplayEditSectionModel) -> Int {
        var index: Int = 0
        
        for i in 0 ..< self.currentState.displaySection.count where self.currentState.displaySection[i].getSectionType() == section.getSectionType() {
            index = i
        }
        
        return index
    }
    
    
    func configureOriginalS3URL(url: String, with filePath: UploadLocation) -> String {
        guard let range = url.range(of: #"[^&?]+"#, options: .regularExpression) else { return "" }
        return String(url[range])
    }
}

