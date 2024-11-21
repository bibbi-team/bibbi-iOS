//
//  CreateEmojiImageRequest.swift
//  Domain
//
//  Created by 김도현 on 11/17/24.
//

import Foundation


public struct CreateEmojiImageRequest {
    public let type: String
    public let imageUrl: String
    
    public init(type: String, imageUrl: String) {
        self.type = type
        self.imageUrl = imageUrl
    }
}
