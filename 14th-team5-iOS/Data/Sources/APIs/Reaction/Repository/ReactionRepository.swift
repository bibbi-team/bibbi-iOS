//
//  ReactionRepository.swift
//  Data
//
//  Created by 마경미 on 04.06.24.
//

import Foundation

import Domain

import RxSwift

public final class ReactionRepository: ReactionRepositoryProtocol {
    
    public let disposeBag: DisposeBag = DisposeBag()
    private let reactionAPIWorker: ReactionAPIWorker = ReactionAPIWorker()
    
    public init () { }
    
    public func addReaction(query: Domain.AddEmojiQuery, body: Domain.AddEmojiBody) -> RxSwift.Single<Void?> {
        reactionAPIWorker.addReaction(query: query, body: body)
    }
    
    public func removeReaction(query: Domain.RemoveEmojiQuery, body: Domain.RemoveEmojiBody) -> RxSwift.Single<Void?> {
        reactionAPIWorker.removeReaction(query: query, body: body)
    }
    
    public func fetchReaction(query: Domain.FetchEmojiQuery) -> RxSwift.Single<[Domain.FetchedEmojiData]?> {
        reactionAPIWorker.fetchReaction(query: query)
    }
}
