import SwiftUI

struct CommentView: View {
    let comment: Comment
    let isCurrentUser: Bool
    let username: String
    let avatar: String? // URL or system name
    let onReply: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Reference comment (reply indicator)
            if let referenceId = comment.referenceCommentId {
                ReplyIndicatorView(referenceId: referenceId)
            }
            
            // Main comment content
            HStack(alignment: .top, spacing: 10) {
                // Message content
                VStack(alignment: .leading, spacing: 4) {
                    // Username and timestamp
                    HeaderView(username: username, timestamp: comment.createdAt, isCurrentUser: isCurrentUser)
                    
                    // Message bubble with avatar
                    HStack(alignment: .center, spacing: 8) {
                        AvatarView(avatar: avatar, username: username)
                        
                        MessageBubbleView(
                            text: comment.text,
                            isCurrentUser: isCurrentUser
                        )
                    }
                    
                    // Actions
                    HStack {
                        Spacer()
                            .frame(width: 36) // Avatar width + spacing
                        
                        ActionsView(
                            onReply: onReply
                        )
                    }
                }
                
                Spacer(minLength: 30) // Ensure some right margin
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
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
            .frame(width: 28, height: 28)
            .clipShape(Circle())
        } else {
            InitialsView(username: username)
        }
    }
}

public struct InitialsView: View {
    let username: String
    
    public var initials: String {
        let components = username.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? (components.last?.first?.uppercased() ?? "") : ""
        return firstInitial + lastInitial
    }
    
    public var backgroundColor: Color {
        // Generate color based on username hash
        let hash = abs(username.hashValue)
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .indigo, .teal]
        return colors[hash % colors.count]
    }
    
    public var body: some View {
        Circle()
            .fill(backgroundColor.gradient)
            .frame(width: 28, height: 28)
            .overlay(
                Text(initials)
                    .font(.system(size: 11, weight: .semibold))
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
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isCurrentUser ? .blue : .primary)
            
            if isCurrentUser && username.lowercased() != "you" {
                Text("You")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.blue.opacity(0.7))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Text(relativeTimeString(from: timestamp))
                .font(.system(size: 11, weight: .regular))
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
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(isCurrentUser ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if isCurrentUser {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        }
                    }
                    .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 0.5)
                )
            
            Spacer()
        }
    }
}

private struct ActionsView: View {
    let onReply: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Reply button
            Button(action: onReply) {
                HStack(spacing: 3) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Reply")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
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
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal, 14)
            .padding(.bottom, 3)
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
                    creatorUsername: "mrman454545",
                    postId: "post1",
                    createdAt: Date().addingTimeInterval(-300),
                    text: "This is a really insightful verse! Thanks for sharing this reflection.",
                    referenceCommentId: nil
                ),
                isCurrentUser: false,
                username: "Sarah Chen",
                avatar: nil,
                onReply: {}
            )
            
            // Current user comment
            CommentView(
                comment: Comment(
                    id: "2",
                    creatorId: "currentUser",
                    creatorUsername: "saytwinucheckin",
                    postId: "post1",
                    createdAt: Date().addingTimeInterval(-120),
                    text: "Absolutely! This passage has been on my heart lately too.",
                    referenceCommentId: nil
                ),
                isCurrentUser: true,
                username: "You",
                avatar: nil,
                onReply: {}
            )
            
            // Reply comment
            CommentView(
                comment: Comment(
                    id: "3",
                    creatorId: "user3",
                    creatorUsername: "saytwinucheckin",
                    postId: "post1",
                    createdAt: Date().addingTimeInterval(-60),
                    text: "Same here! It's amazing how God speaks through His word.",
                    referenceCommentId: "1"
                ),
                isCurrentUser: false,
                username: "Michael Johnson",
                avatar: nil,
                onReply: {}
            )
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}
