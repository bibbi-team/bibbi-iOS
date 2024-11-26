//
//  CreatePostPresignedURLEntity.swift
//  Domain
//
//  Created by 김도현 on 11/22/24.
//

import Foundation


public struct CreatePostPresignedURLEntity {
    public let imageURL: String
    
    public init(imageURL: String) {
        self.imageURL = imageURL
    }
}
