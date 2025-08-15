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
    // TODO: allow for multiple images to be uploaded
    let imagePath: String // file path on firebase storage
    let verses: [BibleClip]
    let likedBy: [String] // string of user ids
    let description: String
    let comments: [Comment]
}
