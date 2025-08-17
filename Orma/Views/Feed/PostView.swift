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
    @State private var showComments = false
    @State private var isLiked = false
    @State private var likeCount: Int = 0
    @State private var showFullDescription = false
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isSubmittingComment = false

    private let gradientColors: [[Color]] = [
        [.red, .orange],
        [.blue, .purple],
        [.green, .yellow],
    ]

    private var userGradient: LinearGradient {
        let index =
            abs(post.creatorDisplayName.hashValue) % gradientColors.count
        return LinearGradient(
            colors: gradientColors[index], startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var userGradientFirstColor: Color {
        let index =
            abs(post.creatorDisplayName.hashValue) % gradientColors.count
        return gradientColors[index].first ?? .blue
    }

    var body: some View {
        VStack(spacing: 0) {
            PostHeader(
                post: post, gradient: userGradient,
                firstColor: userGradientFirstColor,
                showVerseModal: $showVerseModal
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            PostImageView(image: image)

            PostContentView(
                post: post,
                showFullDescription: $showFullDescription,
                showComments: $showComments,
                comments: $comments,
                newCommentText: $newCommentText,
                isSubmittingComment: $isSubmittingComment,
                isLiked: $isLiked,
                userGradientFirstColor: userGradientFirstColor
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if showComments {
                CommentSectionView(
                    postId: post.id
                )
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3), .clear,
                                    .black.opacity(0.1),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .shadow(
            color: userGradientFirstColor.opacity(0.15), radius: 8, x: 0, y: 4
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .onAppear {
            comments = post.comments
            guard let currentUser = OrmaUser.shared.firebaseUser else { return }
            PostService().isLiked(postId: post.id, userId: currentUser.uid) {
                liked in
                isLiked = liked
            }
            PostService().getImage(from: post.imagePath) { image in
                withAnimation(.easeOut(duration: 0.3)) { self.image = image }
            }
        }
        .sheet(isPresented: $showVerseModal) {
            VerseModal(isPresented: $showVerseModal, reference: post.reference)
        }
    }
}

// MARK: - Components

struct PostHeader: View {
    let post: Post
    let gradient: LinearGradient
    let firstColor: Color
    @Binding var showVerseModal: Bool
    @State private var displayName: String = ""

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(gradient)
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(displayName.prefix(1)))
                        .font(
                            .system(
                                size: 14, weight: .bold, design: .rounded)
                        )
                        .foregroundColor(.white)
                }
                .overlay {
                    Circle().stroke(.white.opacity(0.3), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text(displayName)
                        .font(
                            .system(
                                size: 14, weight: .semibold, design: .rounded)
                        )
                        .foregroundColor(.primary)
                }

                Text(timeAgo(from: post.createdAt))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                showVerseModal = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(firstColor)
                    Text(post.reference)
                        .font(.footnote.weight(.medium))
                        .lineLimit(1)
                        .foregroundColor(firstColor)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    LinearGradient(
                        colors: [
                            firstColor.opacity(0.2), firstColor.opacity(0.1),
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
            .contentShape(Rectangle())
        }
        .onAppear {
            loadCreatorName(for: post.creatorId)
        }
    }

    func loadCreatorName(for creatorId: String) {
        PostService().getDisplayName(creatorId: creatorId) {
            name in
            DispatchQueue.main.async {
                self.displayName = name ?? "Unknown user"
            }
        }
    }

    private func timeAgo(from date: Date) -> String {
        let secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 60 {
            return "\(secondsAgo)s"
        } else if secondsAgo < 3600 {
            return "\(secondsAgo / 60)m"
        } else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600)h"
        } else if secondsAgo < 604800 {
            return "\(secondsAgo / 86400)d"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

struct PostImageView: View {
    let image: UIImage?

    var body: some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 225)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.1), .gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 225)
                    .overlay(ProgressView().tint(.blue))
            }
        }
    }
}

struct PostContentView: View {
    let post: Post
    @Binding var showFullDescription: Bool
    @Binding var showComments: Bool
    @Binding var comments: [Comment]
    @Binding var newCommentText: String
    @Binding var isSubmittingComment: Bool
    @Binding var isLiked: Bool
    let userGradientFirstColor: Color

    var body: some View {
        VStack(spacing: 10) {
            if !post.description.isEmpty {
                HStack {
                    Text(post.description)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineLimit(showFullDescription ? nil : 8)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }

            HStack(spacing: 16) {
                Button(action: toggleLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .bold))
                }
                .buttonStyle(
                    GradientCircleButton(
                        gradient: LinearGradient(
                            colors: [.red, .pink], startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                        isToggle: true,
                        isActive: .constant(true)
                    )
                )

                Button {
                    showComments.toggle()
                } label: {
                    Image(
                        systemName: showComments
                            ? "bubble.right.fill" : "bubble.right.fill"
                    )
                    .font(.system(size: 12, weight: .bold))
                }
                .buttonStyle(
                    GradientCircleButton(
                        gradient: LinearGradient(
                            colors: [.blue, .cyan], startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                        isActive: .constant(true)
                    )
                )

                Button {
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 12, weight: .bold))
                }
                .buttonStyle(
                    GradientCircleButton(
                        gradient: LinearGradient(
                            colors: [.green, .mint], startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                        isActive: .constant(true)
                    )
                )

                Spacer()

                if !comments.isEmpty {
                    Button {
                        showComments.toggle()
                    } label: {
                        Text(
                            "\(comments.count) comment\(comments.count == 1 ? "" : "s")"
                        )
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func toggleLike() {
        withAnimation {
            guard let currentUser = OrmaUser.shared.firebaseUser else { return }
            PostService().likePost(postId: post.id, userId: currentUser.uid)
            isLiked.toggle()
        }
    }
}

#Preview {
    let post1 = Post(
        id: "abc123",
        creatorId: "user789",
        creatorDisplayName: "logan_norman",
        createdAt: Date(),
        imagePath:
            "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "Matthew 5:3-10",
        likedBy: ["user456", "user123"],
        description: "This is a sample post description for preview purposes.",
        comments: [
            Comment(
                id: "123", creatorId: "user456", creatorDisplayName: "cheeser",
                postId: "abc123",
                createdAt: Date(), text: "Great post!", referenceCommentId: nil),
            Comment(
                id: "456", creatorId: "user123", creatorDisplayName: "cheeser",
                postId: "abc123",
                createdAt: Date(), text: "Very inspiring.",
                referenceCommentId: "comment001"),
        ]
    )

    let post2 = Post(
        id: "def456",
        creatorId: "user123",
        creatorDisplayName: "another_user",
        createdAt: Date().addingTimeInterval(-86400),
        imagePath:
            "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "John 3:16-17, John 3:18",
        likedBy: [],
        description:
            "Another post sharing a powerful verse. I just drop bars spin out in foreign cars and i look up at the star. You can see me from afar still shining like i'm from mars",
        comments: []
    )

    let post3 = Post(
        id: "ghi789",
        creatorId: "user555",
        creatorDisplayName: "faith_fan",
        createdAt: Date().addingTimeInterval(-3600 * 5),
        imagePath:
            "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "Psalm 23:1-4",
        likedBy: ["user789"],
        description: "Psalm 23 always brings me peace.",
        comments: [
            Comment(
                id: "789", creatorId: "user789",
                creatorDisplayName: "youngbull",
                postId: "ghi789",
                createdAt: Date(), text: "Amen to that!",
                referenceCommentId: nil)
        ]
    )

    PostView(post: post3)
}
