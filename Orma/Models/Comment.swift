//
//  Comment.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import Foundation

struct Comment: Codable {
    let id: String
    let creatorId: String
    let postId: String
    let createdAt: Date
    let text: String
    let referenceComment: String? // another comment id

    enum CodingKeys: String, CodingKey {
        case id, creatorId, postId, createdAt, text, referenceComment
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        creatorId = try container.decode(String.self, forKey: .creatorId)
        postId = try container.decode(String.self, forKey: .postId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        text = try container.decode(String.self, forKey: .text)
        referenceComment = try container.decodeIfPresent(
            String.self, forKey: .referenceComment)
    }

    init(
        id: String,
        creatorId: String,
        postId: String,
        createdAt: Date,
        text: String,
        referenceComment: String? = nil
    ) {
        self.id = id
        self.creatorId = creatorId
        self.postId = postId
        self.createdAt = createdAt
        self.text = text
        self.referenceComment = referenceComment
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(postId, forKey: .postId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(text, forKey: .text)
        try container.encode(referenceComment, forKey: .referenceComment)
    }
}
