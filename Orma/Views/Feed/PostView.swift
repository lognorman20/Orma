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
        VStack {
            Image(post.imagePath)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            Text(post.creatorUsername)
                .font(.largeTitle)
            Text(post.description)
                .font(.subheadline)
            
        }
    }
}

#Preview {
    let post = Post(
        id: "abc123",
        creatorId: "user789",
        creatorUsername: "logan_norman",
        createdAt: Date(),
        imagePath: "logan_hs",
        description: "This is a sample post description for preview purposes.",
        comments: [
            Comment(
                id: "123",
                creatorId: "user456",
                postId: "abc123",
                createdAt: Date(),
                text: "Great post!",
                referenceComment: nil
            ),
            Comment(
                id: "456",
                creatorId: "user123",
                postId: "abc123",
                createdAt: Date(),
                text: "Very inspiring.",
                referenceComment: "comment001"
            )
        ]
    )

    PostView(post: post)
}
