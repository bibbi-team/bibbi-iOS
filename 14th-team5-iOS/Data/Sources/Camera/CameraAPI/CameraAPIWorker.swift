//
//  CameraAPIWorker.swift
//  Data
//
//  Created by Kim dohyun on 12/21/23.
//

import Foundation
import Core

import Alamofire
import Domain
import RxSwift


typealias CameraAPIWorker = CameraAPIs.Worker


extension CameraAPIs {
    final class Worker: APIWorker {
        
        static let queue = {
            ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "CameraAPIQueue", qos: .utility))
        }()
        
        override init() {
            super.init()
            self.id = "CameraAPIWorker"
        }
    }
}


extension CameraAPIWorker {
    public func createPresignedURL(accessToken: String, parameters: Encodable, type: UploadLocation) -> Single<CameraDisplayImageDTO?> {
        let spec = type == .feed ? CameraAPIs.uploadImageURL.spec : CameraAPIs.uploadProfileImageURL.spec
        
        
        return request(spec: spec, headers: [BibbiAPI.Header.xAppKey, BibbiAPI.Header.acceptJson, BibbiAPI.Header.xAuthToken(accessToken)], jsonEncodable: parameters)
            .subscribe(on: Self.queue)
            .do {
                if let str = String(data: $0.1, encoding: .utf8) {
                    debugPrint("uploadImage Fetch Reuslt: \(str)")
                }
            }
            .map(CameraDisplayImageDTO.self)
            .catchAndReturn(nil)
            .asSingle()
    }
    
    public func editProfileImageToS3(accessToken: String, memberId: String, parameters: Encodable) -> Single<ProfileMemberDTO?>   {
        let spec = CameraAPIs.editProfileImage(memberId).spec
        return request(spec: spec, headers: [BibbiAPI.Header.xAppKey, BibbiAPI.Header.acceptJson, BibbiAPI.Header.xAuthToken(accessToken)], jsonEncodable: parameters)
            .subscribe(on: Self.queue)
            .do {
                if let str = String(data: $0.1, encoding: .utf8) {
                    debugPrint("editProfile Image Upload Result: \(str)")
                }
            }
            .map(ProfileMemberDTO.self)
            .catchAndReturn(nil)
            .asSingle()
    }
    
    public func uploadImageToPresignedURL(accessToken: String, toURL url: String, withImageData imageData: Data) -> Single<Bool> {
        let spec = CameraAPIs.presignedURL(url).spec
        return upload(spec: spec, headers: [BibbiAPI.Header.xAppKey, BibbiAPI.Header.xAuthToken(accessToken)], image: imageData)
            .subscribe(on: Self.queue)
            .catchAndReturn(false)
            .debug()
            .map { _ in true }
    }
    
    public func combineWithTextImageUpload(accessToken: String, parameters: Encodable)  -> Single<CameraDisplayPostDTO?> {
        let spec = CameraAPIs.updateImage.spec
        
        return request(spec: spec, headers: [BibbiAPI.Header.xAppKey, BibbiAPI.Header.acceptJson, BibbiAPI.Header.xAuthToken(accessToken)], jsonEncodable: parameters)
            .subscribe(on: Self.queue)
            .do {
                if let str = String(data: $0.1, encoding: .utf8) {
                    debugPrint("editProfile Image Upload Result: \(str)")
                }
            }
            .map(CameraDisplayPostDTO.self)
            .catchAndReturn(nil)
            .asSingle()
        
    }
    
    
    // TODO: Real Emoji API 추가
    public func createRealEmojiPresignedURL(accessToken: String, memberId: String, parameters: Encodable) -> Single<CameraRealEmojiPreSignedDTO?> {
        let spec = CameraAPIs.uploadRealEmojiURL(memberId).spec
        
        return request(spec: spec, headers: [BibbiAPI.Header.xAppKey, BibbiAPI.Header.acceptJson, BibbiAPI.Header.xAuthToken(accessToken)], jsonEncodable: parameters)
            .subscribe(on: Self.queue)
            .do {
                if let str = String(data: $0.1, encoding: .utf8) {
                    debugPrint("upload RealEmoji Image Reuslt: \(str)")
                }
            }
            .map(CameraRealEmojiPreSignedDTO.self)
            .catchAndReturn(nil)
            .asSingle()
        
    }
    
//    public func uploadRealEmojiImageToS3(accessToken: String, memberId: String) -> Single<>
}

