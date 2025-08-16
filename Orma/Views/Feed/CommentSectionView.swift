//
//  CommentSectionView.swift
//  Orma
//
//  Created by Logan Norman on 8/15/25.
//

import SwiftUI

struct CommentSectionView: View {
    let postId: String
    @State private var comments: [Comment] = []
    @State private var newCommentText: String = ""
    @State private var replyingTo: String? = nil // Comment ID being replied to
    @State private var isLoading: Bool = true
    @State private var showingTextField: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Mock current user data - replace with your actual user management
    private let currentUserId = "currentUserId"
    private let currentUsername = "You"
    
    var body: some View {
        VStack(spacing: 0) {
            // Comments header
            HStack {
                Text("Comments")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !comments.isEmpty {
                    Text("\(comments.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            // Comments list
            if isLoading {
                // Loading state
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading comments...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Spacer()
                }
                .frame(minHeight: 200)
            } else if comments.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    VStack(spacing: 4) {
                        Text("No comments yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Be the first to share your thoughts")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .frame(minHeight: 200)
            } else {
                // Comments list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(sortedComments(), id: \.id) { comment in
                            CommentView(
                                comment: comment,
                                isCurrentUser: comment.creatorId == currentUserId,
                                username: getUsernameForComment(comment),
                                avatar: getAvatarForComment(comment),
                                onReply: {
                                    handleReply(to: comment)
                                }
                            )
                            .id(comment.id)
                        }
                        
                        // Bottom padding for better scrolling
                        Color.clear
                            .frame(height: 80)
                    }
                    .padding(.top, 8)
                }
            }
            
            // Reply indicator
            if let replyingToId = replyingTo {
                ReplyingToIndicator(
                    commentId: replyingToId,
                    onCancel: {
                        replyingTo = nil
                        showingTextField = false
                        isTextFieldFocused = false
                    }
                )
            }
            
            // Comment input
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    // User avatar for new comment
                    InitialsView(username: currentUsername)
                        .scaleEffect(0.8)
                    
                    // Text input
                    TextField(
                        replyingTo != nil ? "Write a reply..." : "Add a comment...",
                        text: $newCommentText,
                        axis: .vertical
                    )
                    .font(.system(size: 15, weight: .regular))
                    .lineLimit(1...4)
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        showingTextField = true
                    }
                    
                    // Send button
                    Button(action: submitComment) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .blue)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            loadComments()
        }
        .onChange(of: showingTextField) { showing in
            if showing {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func sortedComments() -> [Comment] {
        return comments.sorted { $0.createdAt < $1.createdAt }
    }
    
    private func getUsernameForComment(_ comment: Comment) -> String {
        if comment.creatorId == currentUserId {
            return currentUsername
        }
        // TODO: Replace with actual user lookup
        // For now, generate mock usernames based on creatorId
        let mockNames = [
            "user1": "Sarah Chen",
            "user2": "Michael Johnson",
            "user3": "Emily Davis",
            "user4": "David Kim",
            "user5": "Rachel Adams"
        ]
        return mockNames[comment.creatorId] ?? "Anonymous"
    }
    
    private func getAvatarForComment(_ comment: Comment) -> String? {
        // TODO: Replace with actual avatar lookup
        // For now, return nil to use initials
        return nil
    }
    
    private func handleReply(to comment: Comment) {
        replyingTo = comment.id
        showingTextField = true
        isTextFieldFocused = true
    }
    
    private func handleLike(comment: Comment) {
        // TODO: Implement like functionality
        print("Liked comment: \(comment.id)")
    }
    
    private func submitComment() {
        let trimmedText = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newComment = Comment(
            id: UUID().uuidString,
            creatorId: currentUserId,
            postId: postId,
            createdAt: Date(),
            text: trimmedText,
            referenceComment: replyingTo
        )
        
        // Add comment locally
        comments.append(newComment)
        
        // TODO: Submit to backend
        print("Submitting comment: \(trimmedText)")
        if let replyId = replyingTo {
            print("Replying to: \(replyId)")
        }
        
        // Reset form
        newCommentText = ""
        replyingTo = nil
        showingTextField = false
        isTextFieldFocused = false
    }
    
    private func loadComments() {
        // TODO: Replace with actual API call
        // Mock data for preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.comments = [
                Comment(
                    id: "1",
                    creatorId: "user1",
                    postId: postId,
                    createdAt: Date().addingTimeInterval(-3600),
                    text: "This verse really spoke to my heart today. Thank you for sharing!",
                    referenceComment: nil
                ),
                Comment(
                    id: "2",
                    creatorId: currentUserId,
                    postId: postId,
                    createdAt: Date().addingTimeInterval(-1800),
                    text: "I'm so glad it blessed you too! God's word is amazing.",
                    referenceComment: nil
                ),
                Comment(
                    id: "3",
                    creatorId: "user2",
                    postId: postId,
                    createdAt: Date().addingTimeInterval(-900),
                    text: "Absolutely! This passage has been on my mind all week.",
                    referenceComment: "1"
                )
            ]
            self.isLoading = false
        }
    }
}

// MARK: - Supporting Views

private struct ReplyingToIndicator: View {
    let commentId: String
    let onCancel: () -> Void
    @State private var replyingToUsername: String = ""
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "arrowshape.turn.up.left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("Replying to")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(replyingToUsername.isEmpty ? "comment" : replyingToUsername)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .onAppear {
            // TODO: Load username for the comment being replied to
            replyingToUsername = "Sarah"
        }
    }
}

// MARK: - Preview

struct CommentSectionView_Previews: PreviewProvider {
    static var previews: some View {
        CommentSectionView(postId: "sample-post-id")
            .previewLayout(.sizeThatFits)
    }
}
