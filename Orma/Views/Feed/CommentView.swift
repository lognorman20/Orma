//
//  CommentView.swift
//  Orma
//
//  Created by Logan Norman on 8/15/25.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    let isCurrentUser: Bool
    let username: String
    let avatar: String? // URL or system name
    let onReply: () -> Void
    let onLike: () -> Void
    @State private var isLiked: Bool = false
    @State private var likeCount: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Reference comment (reply indicator)
            if let referenceId = comment.referenceComment {
                ReplyIndicatorView(referenceId: referenceId)
            }
            
            // Main comment content
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                AvatarView(avatar: avatar, username: username)
                
                // Message content
                VStack(alignment: .leading, spacing: 8) {
                    // Username and timestamp
                    HeaderView(username: username, timestamp: comment.createdAt, isCurrentUser: isCurrentUser)
                    
                    // Message bubble
                    MessageBubbleView(
                        text: comment.text,
                        isCurrentUser: isCurrentUser
                    )
                    
                    // Actions (like, reply, time)
                    ActionsView(
                        isLiked: $isLiked,
                        likeCount: $likeCount,
                        timestamp: comment.createdAt,
                        onReply: onReply,
                        onLike: onLike
                    )
                }
                
                Spacer(minLength: 40) // Ensure some right margin
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

private struct AvatarView: View {
    let avatar: String?
    let username: String
    
    var body: some View {
        if let avatar = avatar, avatar.starts(with: "http") {
            AsyncImage(url: URL(string: avatar)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                InitialsView(username: username)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
        } else {
            InitialsView(username: username)
        }
    }
}

private struct InitialsView: View {
    let username: String
    
    private var initials: String {
        let components = username.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? (components.last?.first?.uppercased() ?? "") : ""
        return firstInitial + lastInitial
    }
    
    private var backgroundColor: Color {
        // Generate color based on username hash
        let hash = abs(username.hashValue)
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .indigo, .teal]
        return colors[hash % colors.count]
    }
    
    var body: some View {
        Circle()
            .fill(backgroundColor.gradient)
            .frame(width: 32, height: 32)
            .overlay(
                Text(initials)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            )
    }
}

private struct HeaderView: View {
    let username: String
    let timestamp: Date
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Text(username)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isCurrentUser ? .blue : .primary)
            
            if isCurrentUser {
                Text("You")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue.opacity(0.7))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Text(relativeTimeString(from: timestamp))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
    
    private func relativeTimeString(from date: Date) -> String {
        let now = Date()
        let difference = now.timeIntervalSince(date)
        
        if difference < 60 {
            return "now"
        } else if difference < 3600 {
            let minutes = Int(difference / 60)
            return "\(minutes)m"
        } else if difference < 86400 {
            let hours = Int(difference / 3600)
            return "\(hours)h"
        } else {
            let days = Int(difference / 86400)
            return "\(days)d"
        }
    }
}

private struct MessageBubbleView: View {
    let text: String
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(isCurrentUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            isCurrentUser
                                ? LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray6)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                )
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}


private struct ActionsView: View {
    @Binding var isLiked: Bool
    @Binding var likeCount: Int
    let timestamp: Date
    let onReply: () -> Void
    let onLike: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Like button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
                onLike()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isLiked ? .red : .secondary)
                        .scaleEffect(isLiked ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLiked)
                    
                    if likeCount > 0 {
                        Text("\(likeCount)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Reply button
            Button(action: onReply) {
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Reply")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Precise timestamp on tap
            Text(DateFormatter.timeFormatter.string(from: timestamp))
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.blue)
        }
        .padding(.leading, 4)
    }
}

private struct ReplyIndicatorView: View {
    let referenceId: String
    @State private var referencedComment: Comment?
    @State private var referencedUsername: String = ""
    
    var body: some View {
        if let referenced = referencedComment {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 3, height: 24)
                    .clipShape(Capsule())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(referencedUsername)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Text(referenced.text)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Preview
struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Regular comment
            CommentView(
                comment: Comment(
                    id: "1",
                    creatorId: "user1",
                    postId: "post1",
                    createdAt: Date().addingTimeInterval(-300),
                    text: "This is a really insightful verse! Thanks for sharing this reflection.",
                    referenceComment: nil
                ),
                isCurrentUser: false,
                username: "Sarah Chen",
                avatar: nil,
                onReply: {},
                onLike: {}
            )
            
            // Current user comment
            CommentView(
                comment: Comment(
                    id: "2",
                    creatorId: "currentUser",
                    postId: "post1",
                    createdAt: Date().addingTimeInterval(-120),
                    text: "Absolutely! This passage has been on my heart lately too.",
                    referenceComment: nil
                ),
                isCurrentUser: true,
                username: "You",
                avatar: nil,
                onReply: {},
                onLike: {}
            )
            
            // Reply comment
            CommentView(
                comment: Comment(
                    id: "3",
                    creatorId: "user3",
                    postId: "post1",
                    createdAt: Date().addingTimeInterval(-60),
                    text: "Same here! It's amazing how God speaks through His word.",
                    referenceComment: "1"
                ),
                isCurrentUser: false,
                username: "Michael Johnson",
                avatar: nil,
                onReply: {},
                onLike: {}
            )
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}
