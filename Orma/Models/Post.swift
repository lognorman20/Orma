//
//  Post.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseDatabase

struct Post: Codable {
    let id: String
    let creatorId: String
    let creatorUsername: String
    let createdAt: Date
    // TODO: allow for multiple images to be uploaded
    let imagePath: String  // file path on firebase storage
    // TODO: allow for multiple references to be stored
    let reference: String
    let likedBy: [String]  // string of user ids
    let description: String
    let comments: [Comment]

    enum CodingKeys: String, CodingKey {
        case id, creatorId, creatorUsername, createdAt, imagePath, reference,
            likedBy, description, comments
    }

    init(
        id: String,
        creatorId: String,
        creatorUsername: String,
        createdAt: Date,
        imagePath: String,
        reference: String,
        likedBy: [String],
        description: String,
        comments: [Comment]
    ) {
        self.id = id
        self.creatorId = creatorId
        self.creatorUsername = creatorUsername
        self.createdAt = createdAt
        self.imagePath = imagePath
        self.reference = reference
        self.likedBy = likedBy
        self.description = description
        self.comments = comments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        creatorId = try container.decode(String.self, forKey: .creatorId)
        creatorUsername = try container.decode(
            String.self, forKey: .creatorUsername)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        imagePath = try container.decode(String.self, forKey: .imagePath)
        reference = try container.decode(String.self, forKey: .reference)
        likedBy = try container.decode([String].self, forKey: .likedBy)
        description = try container.decode(String.self, forKey: .description)
        comments = try container.decode([Comment].self, forKey: .comments)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(creatorUsername, forKey: .creatorUsername)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(imagePath, forKey: .imagePath)
        try container.encode(reference, forKey: .reference)
        try container.encode(likedBy, forKey: .likedBy)
        try container.encode(description, forKey: .description)
        try container.encode(comments, forKey: .comments)
    }
}
