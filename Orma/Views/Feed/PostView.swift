//
//  PostView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct PostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            Image(post.imagePath)
                .resizable()
                .scaledToFill()
                .frame(height: 280)
                .clipped()
                .cornerRadius(20)
                .shadow(radius: 5)
            
            // Creator and date
            HStack {
                Text(post.creatorUsername)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(post.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Bible verses (formatted)
            if !post.verses.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.verses, id: \.id) { clip in
                            Text(clip.humanReadable())
                                .font(.footnote)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Description
            Text(post.description)
                .font(.body)
                .foregroundColor(.primary)
            
            // Likes and comments count
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(post.likedBy.count) likes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(post.comments.count) comments")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding([.horizontal, .top])
    }
}

#Preview {
    let post1 = Post(
        id: "abc123",
        creatorId: "user789",
        creatorUsername: "logan_norman",
        createdAt: Date(),
        imagePath: "logan_hs",
        verses: [
            BibleClip(
                id: "v1", book: "Matthew", chapter: 5, startVerse: 3,
                endVerse: 10)
        ],
        likedBy: ["user456", "user123"],
        description: "This is a sample post description for preview purposes.",
        comments: [
            Comment(
                id: "123", creatorId: "user456", postId: "abc123",
                createdAt: Date(), text: "Great post!", referenceComment: nil),
            Comment(
                id: "456", creatorId: "user123", postId: "abc123",
                createdAt: Date(), text: "Very inspiring.",
                referenceComment: "comment001"),
        ]
    )

    let post2 = Post(
        id: "def456",
        creatorId: "user123",
        creatorUsername: "another_user",
        createdAt: Date().addingTimeInterval(-86400),
        imagePath: "log_spread",
        verses: [
            BibleClip(
                id: "v2", book: "John", chapter: 3, startVerse: 16, endVerse: 17
            ),
            BibleClip(
                id: "v3", book: "John", chapter: 3, startVerse: 18, endVerse: 18
            ),
        ],
        likedBy: [],
        description: "Another post sharing a powerful verse.",
        comments: []
    )

    let post3 = Post(
        id: "ghi789",
        creatorId: "user555",
        creatorUsername: "faith_fan",
        createdAt: Date().addingTimeInterval(-3600 * 5),
        imagePath: "faith_pic",
        verses: [
            BibleClip(
                id: "v4", book: "Psalm", chapter: 23, startVerse: 1, endVerse: 4
            )
        ],
        likedBy: ["user789"],
        description: "Psalm 23 always brings me peace.",
        comments: [
            Comment(
                id: "789", creatorId: "user789", postId: "ghi789",
                createdAt: Date(), text: "Amen to that!", referenceComment: nil)
        ]
    )

    PostView(post: post2)
}
