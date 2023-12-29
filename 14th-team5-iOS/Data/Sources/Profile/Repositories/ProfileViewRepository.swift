//
//  ProfileViewRepository.swift
//  Data
//
//  Created by Kim dohyun on 12/25/23.
//

import Foundation

import Domain
import RxSwift
import RxCocoa





public final class ProfileViewRepository {
        
    public var disposeBag: DisposeBag = DisposeBag()
    private let profileAPIWorker: ProfileAPIWorker = ProfileAPIWorker()
    private let accessToken: String = "eyJhbGciOiJIUzI1NiIsInR5cGUiOiJhY2Nlc3MiLCJyZWdEYXRlIjoxNzAzNzU3MTM1NzcyLCJ0eXAiOiJKV1QifQ.eyJ1c2VySWQiOiIwMUhKQk5YQVYwVFlRMUtFU1dFUjQ1QTJRUCIsImV4cCI6MTcwMzg0MzUzNX0.-lcEBKB_KI32_rI2Ne1fQPMEa1ueGlK9H1TgSuDTehw"
    
    public init() { }
    
}


extension ProfileViewRepository: ProfileViewInterface {
    
    public func fetchProfileMemberItems() -> Observable<ProfileMemberResponse> {
        return profileAPIWorker.fetchProfileMember(accessToken: accessToken, "01HJBNXAV0TYQ1KESWER45A2QP")
            .compactMap { $0?.toDomain() }
            .asObservable()
    }
    
    public func fetchProfilePostItems(query: ProfilePostQuery, parameter: ProfilePostDefaultValue) -> Observable<ProfilePostResponse> {
        
        
        let parameters: ProfilePostParameter = ProfilePostParameter(
            page: query.page,
            size: query.size,
            date: parameter.date,
            memberId: parameter.memberId,
            sort: parameter.sort
        )
        
        print("last parameters: \(parameters)")
        
        return profileAPIWorker.fetchProfilePost(accessToken: accessToken, parameter: parameters)
            .compactMap { $0?.toDomain() }
            .asObservable()
    }
    
    
    public func fetchProfileAlbumImageURL(parameter: CameraDisplayImageParameters) -> Observable<CameraDisplayImageResponse?> {
        return profileAPIWorker.createProfileImagePresingedURL(accessToken: accessToken, parameters: parameter)
            .compactMap { $0?.toDomain() }
            .asObservable()
    }
    
    
    public func uploadProfileImageToPresingedURL(to url: String, imageData: Data) -> Observable<Bool> {
        return profileAPIWorker.uploadToProfilePresingedURL(accessToken: accessToken, toURL: url, with: imageData)
            .asObservable()
    }
    
    public func updataProfileImageToS3(memberId: String, parameter: ProfileImageEditParameter) -> Observable<ProfileMemberResponse?> {
        return profileAPIWorker.updateProfileAlbumImageToS3(accessToken: accessToken, memberId: memberId, parameter: parameter)
            .compactMap { $0?.toDomain() }
            .asObservable()
    }
    
}