//
//  PostView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct PostView: View {
    let post: Post
    @State private var image: UIImage? = nil
    @State private var showVerseModal = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            Group {
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            maxWidth: UIScreen.main.bounds.width * 0.9,
                            maxHeight: 280
                        )
                        .clipped()
                        .cornerRadius(20)
                        .shadow(radius: 5)
                } else {
                    ProgressView()
                        .frame(height: 280)
                }
            }

            // Creator and date
            HStack {
                Text(post.creatorUsername)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(timeAgo(from: post.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Bible verses (formatted)
            if !post.reference.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Text(post.reference)
                            .font(.footnote)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                }
                .onTapGesture {
                    showVerseModal = true
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
        .onAppear {
            PostService().getImage(from: post.imagePath) { image in
                self.image = image
            }
        }
        .sheet(isPresented: $showVerseModal) {
            VerseModal(isPresented: $showVerseModal, reference: post.reference)
        }
    }

    private func timeAgo(from date: Date) -> String {
        let secondsAgo = Int(Date().timeIntervalSince(date))

        if secondsAgo < 60 {
            return "\(secondsAgo)s ago"
        } else if secondsAgo < 3600 {
            return "\(secondsAgo / 60)m ago"
        } else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600)h ago"
        } else {
            return "\(secondsAgo / 86400)d ago"
        }
    }
}

#Preview {
    let post1 = Post(
        id: "abc123",
        creatorId: "user789",
        creatorUsername: "logan_norman",
        createdAt: Date(),
        imagePath: "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "Matthew 5:3-10",
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
        imagePath: "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "John 3:16-17, John 3:18",
        likedBy: [],
        description: "Another post sharing a powerful verse.",
        comments: []
    )

    let post3 = Post(
        id: "ghi789",
        creatorId: "user555",
        creatorUsername: "faith_fan",
        createdAt: Date().addingTimeInterval(-3600 * 5),
        imagePath: "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "Psalm 23:1-4",
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
