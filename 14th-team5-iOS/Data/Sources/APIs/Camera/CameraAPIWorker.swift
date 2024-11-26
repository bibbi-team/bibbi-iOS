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

extension CameraAPIWorker {
            
    /// 리얼 이모지를 업로드 하기 위한 Presigend-URL API 요청 Method 입니다
    /// HTTP Method : POST
    /// - Parameters :
    ///     - MemberId (사용자 멤버 ID)
    ///     - body: CreatePresignedURLReqeustDTO (업로드 Image Name)
    /// - Returns : CameraRealEmojiPreSignedResponseDTO
    public func createRealEmojiPresignedURL(memberId: String, body: CreatePresignedURLReqeustDTO) -> Observable<CameraRealEmojiPreSignedResponseDTO?> {
        let spec = CameraAPIs.createRealEmojiPresignedURL(memberID: memberId, body: body).spec
        
        return request(spec)
    }
    
    /// 리얼 이모지를 조회 하기 위한 API Method 입니다.
    /// HTTP Method : GET
    /// - Parameters : MemberId (사용자 멤버 ID)
    /// - Returns : CameraRealEmojiImageItemResponseDTO
    public func fetchRealEmoji(memberId: String) -> Observable<CameraRealEmojiImageItemResponseDTO?> {
        let spec = CameraAPIs.fetchRealEmojiImage(memberId: memberId).spec
        
        return request(spec)
    }
    
    /// 리얼 이모지를 수정하기 위한 API Method 입니다.
    /// HTTP Method :  PUT
    /// - Parameters
    ///     - MemberId (사용자 멤버 ID)
    ///     - realEmojiId (리얼 이모지 ID)
    /// - Returns : CameraUpdateRealEmojiResponseDTO
    public func updateRealEmoji(memberId: String, realEmojiId: String, body: UpdateRealEmojiImageRequestDTO) -> Observable<CameraUpdateRealEmojiResponseDTO?> {
        let spec = CameraAPIs.updateRealEmojiImage(memberId: memberId, realEmojiId: realEmojiId, body: body).spec
        
        return request(spec)
    }
    
    /// 리얼 이모지를 추가하기 위한 API Method 입니다.
    /// HTTP Method : POST
    ///- Parameters :
    ///     - MemberId (사용자 멤버 ID)
    ///     - body : CreatePresignedURLReqeustDTO
    ///         - type : 리얼 이모지 타입
    ///         - imageUrl : 리얼 이모지 URL
    ///- Returns : CameraCreateRealEmojiResponseDTO
    public func createRealEmoji(memberId: String, body: CreateEmojiImageReqeustDTO) -> Observable<CameraCreateRealEmojiResponseDTO> {
        let spec = CameraAPIs.createRealEmojiImage(memberId: memberId, body: body).spec
        
        return request(spec)
    }
    
    /// 피드, 프로필 이미지를 S3 Bucket에 업로드 하기 위한 Method 입니다.
    /// HTTP Method : PUT
    /// - Parameters
    ///     - presignedURL : 서버에서 발급 받은 Presigned-URL
    ///     - image : Image Data Type
    /// - Returns : 업로드 성공 여부 확인 (Bool) Type
    public func uploadImageToPresignedURL(_ presignedURL: String, image: Data) -> Observable<Bool> {
        return upload(presignedURL, with: image)
    }
    
}
