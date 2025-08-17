//
//  OrmaUser.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftUI

struct OrmaFriend: Identifiable, Codable {
    let id: String
    let displayName: String
    var username: String
}

class OrmaUser: ObservableObject {
    private static var dbRef: DatabaseReference = Database.database()
        .reference()
    static let shared = OrmaUser()

    @Published var firebaseUser: User? = nil
    @Published var username: String = ""
    @Published var friends: [OrmaFriend] = []
    @Published var displayName: String = ""

    let ormaUserId: String = ""

    init() {
        if let currentUser = Auth.auth().currentUser {
            self.firebaseUser = currentUser
            self.displayName = currentUser.displayName ?? "User"
            self.username =
                currentUser.displayName?
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .joined() ?? "User"

            refreshUserData()
        }
    }

    func addFriend() {

    }

    func refreshUserData() {
        guard let user = firebaseUser else { return }
        let userRef = Self.dbRef.child("users").child(user.uid)

        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(),
                let value = snapshot.value as? [String: Any]
            {

                if let savedUsername = value["username"] as? String {
                    DispatchQueue.main.async { self.username = savedUsername }
                }

                if let savedDisplayName = value["displayName"] as? String {
                    DispatchQueue.main.async {
                        self.displayName = savedDisplayName
                    }
                }

                if let friendsArray = value["friends"] as? [[String: Any]] {
                    let loadedFriends = friendsArray.compactMap {
                        dict -> OrmaFriend? in
                        guard let id = dict["id"] as? String,
                            let displayName = dict["displayName"] as? String,
                            let username = dict["username"] as? String
                        else { return nil }
                        return OrmaFriend(
                            id: id, displayName: displayName, username: username
                        )
                    }
                    DispatchQueue.main.async { self.friends = loadedFriends }
                }

            } else {
                let userData: [String: Any] = [
                    "displayName": self.displayName,
                    "username": self.username,
                    "friends": [],
                ]
                userRef.setValue(userData)
            }
        }
    }

    var isLoggedIn: Bool { firebaseUser != nil }
}

class OrmaUserService {
    var dbRef: DatabaseReference! = Database.database().reference()
    var storageRef = Storage.storage().reference()

    func getUserIdIfExists(
        username: String, completion: @escaping (String?) -> Void
    ) {
        let usersRef = dbRef.child("users")
            .queryOrdered(byChild: "username")
            .queryEqual(toValue: username)

        usersRef.observeSingleEvent(of: .value) { snapshot in
            if let child = snapshot.children.allObjects.first as? DataSnapshot {
                completion(child.key)
            } else {
                completion(nil)
            }
        }
    }

    // { friendRequests/fromId/toId/timestamp }
    func sendFriendRequest(friendId: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let requestRef = dbRef.child("friendRequests").child(currentUser.uid)
            .child(friendId)

        requestRef.setValue(ServerValue.timestamp())
    }

    func fetchPendingFriendRequests(
        completion: @escaping ([FriendRequest]) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion([])
            return
        }

        let requestsRef = dbRef.child("friendRequests")
        requestsRef.observeSingleEvent(of: .value) { snapshot in
            var requests: [FriendRequest] = []

            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let fromId = child.key
                if let toDict = child.value as? [String: Any] {
                    for (toId, value) in toDict {
                        let timestamp: String
                        if let ts = value as? Double {
                            let date = Date(timeIntervalSince1970: ts / 1000)
                            let formatter = DateFormatter()
                            formatter.dateStyle = .short
                            formatter.timeStyle = .short
                            timestamp = formatter.string(from: date)
                        } else {
                            timestamp = ""
                        }
                        let request = FriendRequest(
                            fromId: fromId, toId: toId, timestamp: timestamp)
                        if toId == currentUser.uid {
                            requests.append(request)
                        }
                    }
                }
            }

            completion(requests)
        }
    }
    
    func declineFriendRequest(friendId: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserId = currentUser.uid
        
        let requestRef = dbRef.child("friendRequests").child(friendId).child(currentUserId)
        requestRef.removeValue()
    }
    
    func fetchAllFriends(userId: String, completion: @escaping ([OrmaFriend]) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("users").child(userId).child("friends").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion([])
                print("No friends found for user")
                return
            }

            var friends: [OrmaFriend] = []
            
            // Handle both array and dictionary structures
            if let friendsArray = snapshot.value as? [[String: Any]] {
                // If friends is stored as an array
                for friendData in friendsArray {
                    if let friendId = friendData["id"] as? String,
                       let displayName = friendData["displayName"] as? String,
                       let username = friendData["username"] as? String {
                        
                        let friend = OrmaFriend(
                            id: friendId,
                            displayName: displayName,
                            username: username
                        )
                        friends.append(friend)
                    }
                }
            } else if let friendDict = snapshot.value as? [String: Any] {
                // If friends is stored as a dictionary with numeric keys
                for (_, value) in friendDict {
                    if let friendData = value as? [String: Any],
                       let friendId = friendData["id"] as? String,
                       let displayName = friendData["displayName"] as? String,
                       let username = friendData["username"] as? String {
                        
                        let friend = OrmaFriend(
                            id: friendId,
                            displayName: displayName,
                            username: username
                        )
                        friends.append(friend)
                    }
                }
            } else {
                // Handle unexpected data structure
                print("Unexpected friends data structure: \(snapshot.value ?? "nil")")
                completion([])
                return
            }

            let sortedFriends = friends.sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
            completion(sortedFriends)
            
        } withCancel: { error in
            print("Error fetching friends: \(error.localizedDescription)")
            completion([])
        }
    }
    
    func addFriend(friendId: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserId = currentUser.uid

        let usersRef = dbRef.child("users")

        // Fetch both user profiles
        usersRef.child(currentUserId).observeSingleEvent(of: .value) {
            currentSnap in
            usersRef.child(friendId).observeSingleEvent(of: .value) {
                friendSnap in
                guard
                    let currentData = currentSnap.value as? [String: Any],
                    let friendData = friendSnap.value as? [String: Any],
                    let currentDisplayName = currentData["displayName"]
                        as? String,
                    let currentUsername = currentData["username"] as? String,
                    let friendDisplayName = friendData["displayName"]
                        as? String,
                    let friendUsername = friendData["username"] as? String
                else { return }

                let currentFriend = [
                    "id": friendId,
                    "displayName": friendDisplayName,
                    "username": friendUsername,
                ]

                let newFriend = [
                    "id": currentUserId,
                    "displayName": currentDisplayName,
                    "username": currentUsername,
                ]

                // Add friend to current user
                usersRef.child(currentUserId).child("friends")
                    .observeSingleEvent(of: .value) { snap in
                        var friends = snap.value as? [[String: Any]] ?? []
                        if !friends.contains(where: {
                            ($0["id"] as? String) == friendId
                        }) {
                            friends.append(currentFriend)
                            usersRef.child(currentUserId).child("friends")
                                .setValue(friends)
                        }
                    }

                // Add current user to friend
                usersRef.child(friendId).child("friends").observeSingleEvent(
                    of: .value
                ) { snap in
                    var friends = snap.value as? [[String: Any]] ?? []
                    if !friends.contains(where: {
                        ($0["id"] as? String) == currentUserId
                    }) {
                        friends.append(newFriend)
                        usersRef.child(friendId).child("friends").setValue(
                            friends)
                    }
                }
            }
        }
        
        // remove friend request from requests
        let requestsRef = dbRef.child("friendRequests")
        requestsRef.child(currentUserId).child(friendId).removeValue()
        requestsRef.child(friendId).child(currentUserId).removeValue()
    }

    func removeFriend(friendId: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserId = currentUser.uid

        let usersRef = dbRef.child("users")

        // Remove friend from current user
        usersRef.child(currentUserId).child("friends").observeSingleEvent(
            of: .value
        ) { snap in
            var friends = snap.value as? [[String: Any]] ?? []
            friends.removeAll { ($0["id"] as? String) == friendId }
            usersRef.child(currentUserId).child("friends").setValue(friends)
        }

        // Remove current user from friend
        usersRef.child(friendId).child("friends").observeSingleEvent(of: .value)
        { snap in
            var friends = snap.value as? [[String: Any]] ?? []
            friends.removeAll { ($0["id"] as? String) == currentUserId }
            usersRef.child(friendId).child("friends").setValue(friends)
        }
    }
}
