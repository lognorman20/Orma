//
//  CommentSectionView.swift
//  Orma
//
//  Created by Logan Norman on 8/15/25.
//

import SwiftUI

struct CommentSectionView: View {
    let postId: String
    @State private var newCommentText: String = ""
    @State private var replyingTo: String? = nil
    @State private var isLoading: Bool = true
    @State private var showingTextField: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentUserId: String = ""
    @State private var currentUsername: String = ""
    @StateObject var commentViewModel: CommentViewModel

    init(postId: String, viewModel: CommentViewModel = CommentViewModel()) {
        self.postId = postId
        _commentViewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Comments header
            HStack {
                Text("Comments")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                if !commentViewModel.comments.isEmpty {
                    Text("\(commentViewModel.comments.count)")
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

            // Comments content
            if commentViewModel.comments.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.6))

                    VStack(spacing: 4) {
                        Text("No comments yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("Be the first to share your thoughts")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            } else {
                // Comments list - dynamic height based on content
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
                }
                .padding(.vertical, 8)
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
                        replyingTo != nil
                            ? "Write a reply..." : "Add a comment...",
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
                            .foregroundColor(
                                newCommentText.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty ? .secondary : .blue)
                    }
                    .disabled(
                        newCommentText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 0
                ))
        }
        .onAppear {
            currentUserId = getCurrentUserId()
            currentUsername = getCurrentUsername()
            loadComments()
        }
        .onChange(of: showingTextField) { _, showing in
            if showing {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Helper Functions

    private func sortedComments() -> [Comment] {
        return commentViewModel.comments.sorted { $0.createdAt < $1.createdAt }
    }

    private func getUsernameForComment(_ comment: Comment) -> String {
        if comment.creatorId == currentUserId {
            return currentUsername
        }

        // TODO: shift this to query firebase?
        return comment.creatorUsername
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

    private func submitComment() {
        let trimmedText = newCommentText.trimmingCharacters(
            in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        print("Submitting comment: \(trimmedText)")
        Task {
            do {
                let referenceId = replyingTo
                try await PostService().createComment(
                    postId: postId,
                    text: trimmedText,
                    referenceCommentId: referenceId
                )
                if let replyId = referenceId {
                    print("Replying to: \(replyId)")
                }
            } catch {
                print("Failed to create comment:", error)
            }
        }

        // Reset form
        newCommentText = ""
        replyingTo = nil
        showingTextField = false
        isTextFieldFocused = false
    }

    private func loadComments() {
        commentViewModel.refreshComments(postId: postId)
        isLoading = false
    }

    public func getCurrentUserId() -> String {
        guard let uid = OrmaUser.shared.user?.uid else {
            fatalError("No current user found")
        }
        return uid
    }

    public func getCurrentUsername() -> String {
        guard let username = OrmaUser.shared.user?.displayName else {
            fatalError("No current user found")
        }
        return username
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

                Text(
                    replyingToUsername.isEmpty ? "comment" : replyingToUsername
                )
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
        CommentSectionView(postId: "cheese")
            .previewLayout(.sizeThatFits)
    }
}
