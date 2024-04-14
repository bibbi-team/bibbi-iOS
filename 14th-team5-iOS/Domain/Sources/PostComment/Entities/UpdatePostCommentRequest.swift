//
//  UpdatePostCommentQuery.swift
//  Domain
//
//  Created by 김건우 on 1/17/24.
//

import Foundation

public struct UpdatePostCommentRequest {
    public var content: String
    
    public init(content: String) {
        self.content = content
    }
}
