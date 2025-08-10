//
//  Post.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import Foundation

struct Post {
    let id: String
    let creatorId: String
    let creatorUsername: String
    let createdAt: Date
    let imagePath: String
    let description: String
    let comments: [Comment]
}
