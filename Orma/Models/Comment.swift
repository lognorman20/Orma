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
    let creatorUsername: String
    let postId: String
    let createdAt: Date
    let text: String
    let referenceCommentId: String?

    enum CodingKeys: String, CodingKey {
        case id, creatorId, creatorUsername, postId, createdAt, text, referenceCommentId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        creatorId = try container.decode(String.self, forKey: .creatorId)
        creatorUsername = try container.decode(String.self, forKey: .creatorUsername)
        postId = try container.decode(String.self, forKey: .postId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        text = try container.decode(String.self, forKey: .text)
        referenceCommentId = try container.decodeIfPresent(
            String.self, forKey: .referenceCommentId)
    }

    init(
        id: String,
        creatorId: String,
        creatorUsername: String,
        postId: String,
        createdAt: Date,
        text: String,
        referenceCommentId: String? = nil
    ) {
        self.id = id
        self.creatorId = creatorId
        self.creatorUsername = creatorUsername
        self.postId = postId
        self.createdAt = createdAt
        self.text = text
        self.referenceCommentId = referenceCommentId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(creatorUsername, forKey: .creatorUsername)
        try container.encode(postId, forKey: .postId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(text, forKey: .text)
        try container.encode(referenceCommentId, forKey: .referenceCommentId)
    }
}
