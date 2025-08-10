//
//  Comment.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import Foundation

struct Comment {
    let id: String
    let creatorId: String
    let postId: String
    let createdAt: Date
    let text: String
    let referenceComment: String?
}
