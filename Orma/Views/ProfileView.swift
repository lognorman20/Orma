//
//  ProfileView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import FirebaseDatabase
import SwiftUI

// MARK: - Main ProfileView
struct ProfileView: View {
    @State private var user: OrmaUser = OrmaUser.shared
    @State private var newFriendUsername: String = ""
    @State private var usernameMatches: [String] = []
    @State private var selectedTab: FriendsTab = .friends
    @State private var pendingFriendRequests: [FriendRequest] = []
    @FocusState private var isUsernameFocused: Bool

    enum FriendsTab: String, CaseIterable {
        case friends = "Friends"
        case requests = "Requests"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ProfileHeaderView(user: user, onSignOut: signOut)

                    AddFriendSectionView(
                        newFriendUsername: $newFriendUsername,
                        usernameMatches: $usernameMatches,
                        isUsernameFocused: $isUsernameFocused,
                        onSendFriendRequest: sendFriendRequest,
                        onFetchMatches: fetchUsernameMatches
                    )

                    FriendsSectionView(
                        user: user,
                        onAcceptRequest: acceptFriendRequest,
                        onDeclineRequest: declineFriendRequest,
                        selectedTab: $selectedTab
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .refreshable {
                getFriendRequests()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGray6),
                        Color(.systemGray5).opacity(0.3),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            user = OrmaUser.shared
            getFriendRequests()
        }
    }

    // MARK: - Computed Properties
    func getFriendRequests() {
        OrmaUserService().fetchPendingFriendRequests { requests in
            DispatchQueue.main.async {
                self.pendingFriendRequests = requests
            }
        }
    }

    // MARK: - Methods
    func sendFriendRequest() {
        let trimmedUsername = newFriendUsername.trimmingCharacters(
            in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }

        OrmaUserService().getUserIdIfExists(username: trimmedUsername) {
            friendId in
            if let friendId = friendId {
                OrmaUserService().sendFriendRequest(friendId: friendId)
            } else {
                print("Username does not exist in Firebase.")
            }
        }

        newFriendUsername = ""
    }

    private func acceptFriendRequest(_ request: FriendRequest) {
        OrmaUserService().addFriend(friendId: request.fromId)
        getFriendRequests()
    }

    private func declineFriendRequest(_ request: FriendRequest) {
        OrmaUserService().declineFriendRequest(friendId: request.fromId)
        getFriendRequests()
    }

    private func fetchUsernameMatches(for query: String) {
        guard !query.isEmpty else {
            usernameMatches = []
            return
        }

        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserId = currentUser.uid
        let usersRef = Database.database().reference().child("users")

        // Fetch current user's friends first
        usersRef.child(currentUserId).child("friends").observeSingleEvent(
            of: .value
        ) { snap in
            let currentFriendIds: [String] =
                (snap.value as? [[String: Any]])?.compactMap {
                    $0["id"] as? String
                } ?? []

            // Now query users by username
            usersRef.queryOrdered(byChild: "username")
                .queryStarting(atValue: query)
                .queryEnding(atValue: query + "\u{f8ff}")
                .observeSingleEvent(of: .value) { snapshot in
                    var results: [String] = []
                    for child in snapshot.children {
                        if let snap = child as? DataSnapshot,
                            let dict = snap.value as? [String: Any],
                            let username = dict["username"] as? String,
                            snap.key != currentUserId,
                            !currentFriendIds.contains(snap.key)
                        {
                            results.append(username)
                        }
                    }
                    self.usernameMatches = results
                }
        }
    }

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            KeychainService.clearAll()
            OrmaUser.shared.firebaseUser = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// MARK: - ProfileHeaderView
struct ProfileHeaderView: View {
    let user: OrmaUser
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ProfileAvatarView(displayName: user.displayName)

            VStack(spacing: 4) {
                Text(user.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                SignOutButtonView(onSignOut: onSignOut)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - ProfileAvatarView
struct ProfileAvatarView: View {
    let displayName: String

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)

            Text(initials(from: displayName))
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }

    private func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first?.uppercased() }
        return initials.joined()
    }
}

// MARK: - SignOutButtonView
struct SignOutButtonView: View {
    let onSignOut: () -> Void

    var body: some View {
        Button(action: onSignOut) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)

                Text("Sign Out")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.red.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.top, 8)
    }
}

// MARK: - AddFriendSectionView
struct AddFriendSectionView: View {
    @Binding var newFriendUsername: String
    @Binding var usernameMatches: [String]
    var isUsernameFocused: FocusState<Bool>.Binding
    let onSendFriendRequest: () -> Void
    let onFetchMatches: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AddFriendHeaderView()

            VStack(alignment: .leading, spacing: 0) {
                AddFriendTextFieldView(
                    newFriendUsername: $newFriendUsername,
                    isUsernameFocused: isUsernameFocused,
                    onFetchMatches: onFetchMatches,
                    onSendFriendRequest: onSendFriendRequest
                )

                if isUsernameFocused.wrappedValue && !newFriendUsername.isEmpty
                    && !usernameMatches.isEmpty
                {
                    UsernameMatchesView(
                        matches: usernameMatches,
                        onSelectMatch: { match in
                            newFriendUsername = match
                            isUsernameFocused.wrappedValue = false
                        }
                    )
                }
            }

            AddFriendButtonView(
                isDisabled: newFriendUsername.isEmpty,
                onTap: onSendFriendRequest
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - AddFriendHeaderView
struct AddFriendHeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.badge.plus")
                .foregroundColor(.blue)
                .font(.title3)

            Text("Add Friend")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - AddFriendTextFieldView
struct AddFriendTextFieldView: View {
    @Binding var newFriendUsername: String
    var isUsernameFocused: FocusState<Bool>.Binding
    let onFetchMatches: (String) -> Void
    let onSendFriendRequest: () -> Void

    var body: some View {
        TextField("Enter friend's username", text: $newFriendUsername)
            .textFieldStyle(.roundedBorder)
            .focused(isUsernameFocused)
            .onChange(of: newFriendUsername) { _, newValue in
                onFetchMatches(newValue)
            }
            .onSubmit {
                isUsernameFocused.wrappedValue = false
                onSendFriendRequest()
            }
    }
}

// MARK: - UsernameMatchesView
struct UsernameMatchesView: View {
    let matches: [String]
    let onSelectMatch: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(matches.prefix(5), id: \.self) { match in
                UsernameMatchRowView(
                    username: match,
                    isLast: match == matches.prefix(5).last,
                    onTap: { onSelectMatch(match) }
                )
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.top, 4)
    }
}

// MARK: - UsernameMatchRowView
struct UsernameMatchRowView: View {
    let username: String
    let isLast: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(username)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .onTapGesture(perform: onTap)

            if !isLast {
                Divider().padding(.leading, 16)
            }
        }
    }
}

// MARK: - AddFriendButtonView
struct AddFriendButtonView: View {
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("Add")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDisabled ? Color.gray : Color.blue)
                )
        }
        .disabled(isDisabled)
    }
}

// MARK: - FriendsSectionView
struct FriendsSectionView: View {
    let user: OrmaUser
    let onAcceptRequest: (FriendRequest) -> Void
    let onDeclineRequest: (FriendRequest) -> Void
    @Binding var selectedTab: ProfileView.FriendsTab
    @State public var pendingRequests: [FriendRequest] = []
    @State public var friends: [OrmaFriend] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            FriendsSectionHeaderView(
                selectedTab: selectedTab,
                friendsCount: friends.count,
                requestsCount: pendingRequests.count
            )

            FriendsTabSelectorView(selectedTab: $selectedTab)

            Group {
                if selectedTab == .friends {
                    FriendsListView(friends: friends)
                } else {
                    FriendRequestsListView(
                        requests: pendingRequests,
                        onAccept: onAcceptRequest,
                        onDecline: onDeclineRequest
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .onAppear {
            getFriends()
            getFriendRequests()
        }
        .refreshable {
            getFriends()
            getFriendRequests()
        }
    }

    func getFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        OrmaUserService().fetchAllFriends(userId: currentUserId) {
            fetchedFriends in
            DispatchQueue.main.async {
                self.friends = fetchedFriends
            }
        }
    }
    
    func getFriendRequests() {
        OrmaUserService().fetchPendingFriendRequests { requests in
            DispatchQueue.main.async {
                self.pendingRequests = requests
            }
        }
    }
}

// MARK: - FriendsSectionHeaderView
struct FriendsSectionHeaderView: View {
    let selectedTab: ProfileView.FriendsTab
    let friendsCount: Int
    let requestsCount: Int

    var body: some View {
        HStack {
            Image(systemName: selectedTab == .friends ? "person.2" : "envelope")
                .foregroundColor(selectedTab == .friends ? .green : .orange)
                .font(.title3)

            Text(selectedTab == .friends ? "Your Friends" : "Friend Requests")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Text("\(selectedTab == .friends ? friendsCount : requestsCount)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(selectedTab == .friends ? .green : .orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(
                            selectedTab == .friends ? Color.green : Color.orange
                        )
                )
        }
    }
}

// MARK: - FriendsTabSelectorView
struct FriendsTabSelectorView: View {
    @Binding var selectedTab: ProfileView.FriendsTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileView.FriendsTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(
                                selectedTab == tab ? .semibold : .medium
                            )
                            .foregroundColor(
                                selectedTab == tab ? .primary : .secondary)

                        Rectangle()
                            .fill(
                                selectedTab == tab
                                    ? (tab == .friends ? .green : .orange)
                                    : .clear
                            )
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - FriendsListView
struct FriendsListView: View {
    let friends: [Friend]  // Assuming Friend is your friend model type

    var body: some View {
        if friends.isEmpty {
            EmptyFriendsView()
        } else {
            LazyVStack(spacing: 8) {
                ForEach(friends, id: \.id) { friend in
                    FriendRowView(friend: friend)
                }
            }
        }
    }
}

// MARK: - EmptyFriendsView
struct EmptyFriendsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2.slash")
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.5))

            Text("No friends added yet")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Add your first friend above!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - FriendRowView
struct FriendRowView: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(
                displayName: friend.displayName,
                colors: [.purple, .pink],
                size: 40
            )

            Text(friend.displayName)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - FriendRequestsListView
struct FriendRequestsListView: View {
    let requests: [FriendRequest]
    let onAccept: (FriendRequest) -> Void
    let onDecline: (FriendRequest) -> Void

    var body: some View {
        if requests.isEmpty {
            EmptyRequestsView()
        } else {
            LazyVStack(spacing: 12) {
                ForEach(requests, id: \.fromId) { request in
                    FriendRequestRowView(
                        request: request,
                        onAccept: { onAccept(request) },
                        onDecline: { onDecline(request) }
                    )
                }
            }
        }
    }
}

// MARK: - EmptyRequestsView
struct EmptyRequestsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "envelope.open")
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.5))

            Text("No pending requests")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Friend requests will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - FriendRequestRowView
struct FriendRequestRowView: View {
    let request: FriendRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    @State private var displayName: String = ""

    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(
                displayName: displayName,
                colors: [.orange, .red],
                size: 40
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("sent a friend request")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            FriendRequestActionsView(
                onAccept: onAccept,
                onDecline: onDecline
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .onAppear {
            getDisplayName(from: request)
        }
    }

    func getDisplayName(from request: FriendRequest) {
        PostService().getDisplayName(creatorId: request.fromId) { name in
            DispatchQueue.main.async {
                self.displayName = name ?? "Unknown Person"
            }
        }
    }
}

// MARK: - FriendRequestActionsView
struct FriendRequestActionsView: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onAccept) {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.green))
            }

            Button(action: onDecline) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.red))
            }
        }
    }
}

// MARK: - UserAvatarView (Reusable)
struct UserAvatarView: View {
    let displayName: String
    let colors: [Color]
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Text(initials(from: displayName))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }

    private func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first?.uppercased() }
        return initials.joined()
    }
}

// MARK: - Supporting Models
struct FriendRequest {
    let fromId: String
    let toId: String
    let timestamp: String
}

// Assuming you have a Friend model - adjust as needed
typealias Friend = OrmaFriend  // Replace with your actual Friend model

#Preview {
    ProfileView()
}
