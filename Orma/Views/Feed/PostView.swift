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
    @State private var showCommentsSheet = false
    @State private var isLiked = false
    @State private var likeCount: Int = 0
    @State private var showFullDescription = false
    @State private var comments: [Comment] = []

    private let gradients = [
        LinearGradient(
            colors: [.pink, .orange], startPoint: .topLeading,
            endPoint: .bottomTrailing),
        LinearGradient(
            colors: [.blue, .purple], startPoint: .topLeading,
            endPoint: .bottomTrailing),
        LinearGradient(
            colors: [.green, .cyan], startPoint: .topLeading,
            endPoint: .bottomTrailing),
        LinearGradient(
            colors: [.red, .pink], startPoint: .topLeading,
            endPoint: .bottomTrailing),
        LinearGradient(
            colors: [.yellow, .orange], startPoint: .topLeading,
            endPoint: .bottomTrailing),
    ]

    private let gradientColors: [[Color]] = [
        [.red, .orange],
        [.blue, .purple],
        [.green, .yellow],
    ]

    private var userGradient: LinearGradient {
        let index = abs(post.creatorUsername.hashValue) % gradientColors.count
        return LinearGradient(
            colors: gradientColors[index], startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    private var userGradientFirstColor: Color {
        let index = abs(post.creatorUsername.hashValue) % gradientColors.count
        return gradientColors[index].first ?? .blue
    }

    var body: some View {
        VStack(spacing: 0) {
            // Compact header
            HStack(spacing: 10) {
                Circle()
                    .fill(userGradient)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(String(post.creatorUsername.prefix(1)))
                            .font(
                                .system(
                                    size: 14, weight: .bold, design: .rounded)
                            )
                            .foregroundColor(.white)
                    }
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 1) {
                    Text(post.creatorUsername)
                        .font(
                            .system(
                                size: 14, weight: .semibold, design: .rounded)
                        )
                        .foregroundColor(.primary)

                    Text(timeAgo(from: post.createdAt))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    showVerseModal = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(userGradientFirstColor)

                        Text(post.reference)
                            .font(.footnote.weight(.medium))
                            .lineLimit(1)
                            .foregroundColor(userGradientFirstColor)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        LinearGradient(
                            colors: [
                                userGradientFirstColor.opacity(0.2),
                                userGradientFirstColor.opacity(0.1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)

                }
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Compact image section
            ZStack {
                Group {
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .gray.opacity(0.1), .gray.opacity(0.2),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200)
                            .overlay {
                                ProgressView()
                                    .tint(.blue)
                            }
                    }
                }
            }

            // Compact content section
            VStack(spacing: 10) {
                // Description
                if !post.description.isEmpty {
                    HStack {
                        Text(post.description)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.primary)
                            .lineLimit(showFullDescription ? nil : 8)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                }

                // Colorful interaction bar
                HStack(spacing: 16) {
                    // Like button (red)
                    Button(action: {
                        withAnimation {
                            if let currentUser = OrmaUser.shared.user {
                                PostService().likePost(postId: post.id, userId: currentUser.uid)
                                isLiked.toggle()
                            } else {
                                print("failed to like post")
                            }
                        }
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(GradientCircleButton(
                        gradient: LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isToggle: true,
                        isActive: .constant(true)
                    ))

                    // Comment button (blue) - Updated to show comments sheet
                    Button(action: {
                        showCommentsSheet = true
                    }) {
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(GradientCircleButton(
                        gradient: LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isActive: .constant(true)
                    ))

                    // Share button (green)
                    Button(action: {}) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(GradientCircleButton(
                        gradient: LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isActive: .constant(true)
                    ))

                    Spacer()
                    
                    // Comment count indicator
                    if !comments.isEmpty {
                        Text("\(comments.count) comment\(comments.count == 1 ? "" : "s")")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
            color: userGradientFirstColor.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .onAppear {
            // Load existing comments
            comments = post.comments
            
            if let currentUser = OrmaUser.shared.user {
                PostService().isLiked(postId: post.id, userId: currentUser.uid) { liked in
                    isLiked = liked
                }
            }
            
            PostService().getImage(from: post.imagePath) { image in
                withAnimation(.easeOut(duration: 0.3)) {
                    self.image = image
                }
            }
        }
        .sheet(isPresented: $showVerseModal) {
            VerseModal(isPresented: $showVerseModal, reference: post.reference)
        }
        .sheet(isPresented: $showCommentsSheet) {
            CommentsView(post: post, comments: $comments)
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

// MARK: - CommentsView
struct CommentsView: View {
    let post: Post
    @Binding var comments: [Comment]
    @State private var newCommentText = ""
    @State private var isSubmittingComment = false
    @Environment(\.dismiss) private var dismiss
    
    private let gradientColors: [[Color]] = [
        [.red, .orange],
        [.blue, .purple],
        [.green, .yellow],
    ]
    
    private func userGradient(for username: String) -> LinearGradient {
        let index = abs(username.hashValue) % gradientColors.count
        return LinearGradient(
            colors: gradientColors[index],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    Text("Comments")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button("") {}
                        .opacity(0)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // Comments List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(comments, id: \.id) { comment in
                            CommentRow(comment: comment, userGradient: userGradient)
                        }
                        
                        if comments.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.secondary)
                                
                                Text("No comments yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Be the first to share your thoughts!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        }
                    }
                    .padding()
                }
                
                // Comment Input
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        // User avatar
                        if let currentUser = OrmaUser.shared.user {
                            Circle()
                                .fill(userGradient(for: currentUser.displayName ?? "Lebron"))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Text(String(currentUser.displayName!.prefix(1) ?? "Lebron"))
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                        }
                        
                        // Text field
                        TextField("Add a comment...", text: $newCommentText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(1...4)
                        
                        // Send button
                        Button(action: submitComment) {
                            if isSubmittingComment {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .blue)
                            }
                        }
                        .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingComment)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
        }
    }
    
    private func submitComment() {
        guard let currentUser = OrmaUser.shared.user,
              !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isSubmittingComment = true
        
        let newComment = Comment(
            id: UUID().uuidString,
            creatorId: currentUser.uid,
            postId: post.id,
            createdAt: Date(),
            text: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines),
            referenceComment: nil
        )
        
        // Add comment to local state immediately for better UX
        comments.append(newComment)
        newCommentText = ""
        
        // TODO: Add your actual comment submission logic here
        // PostService().addComment(comment: newComment) { success in
        //     DispatchQueue.main.async {
        //         isSubmittingComment = false
        //         if !success {
        //             // Remove the comment if submission failed
        //             comments.removeAll { $0.id == newComment.id }
        //         }
        //     }
        // }
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmittingComment = false
        }
    }
}

// MARK: - CommentRow
struct CommentRow: View {
    let comment: Comment
    let userGradient: (String) -> LinearGradient
    
    // Mock username - in real app, you'd fetch this from user service
    private var username: String {
        // This is a placeholder - you'd want to fetch the actual username
        return "user_\(comment.creatorId.suffix(4))"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // User avatar
            Circle()
                .fill(userGradient(username))
                .frame(width: 32, height: 32)
                .overlay {
                    Text(String(username.prefix(1)))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(username)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(timeAgo(from: comment.createdAt))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Text(comment.text)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
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

#Preview {
    let post1 = Post(
        id: "abc123",
        creatorId: "user789",
        creatorUsername: "logan_norman",
        createdAt: Date(),
        imagePath:
            "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
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
        imagePath:
            "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "John 3:16-17, John 3:18",
        likedBy: [],
        description: "Another post sharing a powerful verse. I just drop bars spin out in foreign cars and i look up at the star. You can see me from afar still shining like i'm from mars",
        comments: []
    )

    let post3 = Post(
        id: "ghi789",
        creatorId: "user555",
        creatorUsername: "faith_fan",
        createdAt: Date().addingTimeInterval(-3600 * 5),
        imagePath:
            "https://firebasestorage.googleapis.com:443/v0/b/orma-b48d0.firebasestorage.app/o/pTGsHIXWfDSnhu681SRusfbT2cu1%2F030373A6-8A02-4153-84CC-55647100BF09.jpg?alt=media&token=aff42a3b-c568-4826-9d2b-1d130e3de2ee",
        reference: "Psalm 23:1-4",
        likedBy: ["user789"],
        description: "Psalm 23 always brings me peace.",
        comments: [
            Comment(
                id: "789", creatorId: "user789", postId: "ghi789",
                createdAt: Date(), text: "Amen to that!", referenceComment: nil)
        ]
    )

    PostView(post: post3)
}
