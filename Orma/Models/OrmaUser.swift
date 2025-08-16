//
//  OrmaUser.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import FirebaseDatabase
import SwiftUI

struct OrmaFriend: Identifiable, Codable {
    let id: String        // UID
    let displayName: String
    var username: String  // app-defined
}

class OrmaUser: ObservableObject {
    private static var dbRef: DatabaseReference = Database.database().reference()
    
    static var shared: OrmaUser = {
        guard let currentUser = Auth.auth().currentUser else {
            fatalError("Firebase user must be logged in to initialize OrmaUser")
        }
        guard let displayName = currentUser.displayName, !displayName.isEmpty else {
            fatalError("Firebase user must have a displayName")
        }
        return OrmaUser(firebaseUser: currentUser, displayName: displayName)
    }()

    @Published var firebaseUser: User
    @Published var username: String   // app-defined
    @Published var friends: [OrmaFriend]
    // TODO: add profile pics here

    let ormaUserId: String
    let displayName: String           // from Firebase

    private init(firebaseUser: User, displayName: String) {
        self.firebaseUser = firebaseUser
        self.ormaUserId = firebaseUser.uid
        self.displayName = displayName
        self.username = displayName
        self.friends = []

        // Check if user exists in database
        let userRef = Self.dbRef.child("users").child(ormaUserId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // User exists, load username and friends
                if let value = snapshot.value as? [String: Any] {
                    if let savedUsername = value["username"] as? String {
                        DispatchQueue.main.async {
                            self.username = savedUsername
                        }
                    }
                    if let friendsArray = value["friends"] as? [[String: Any]] {
                        let loadedFriends = friendsArray.compactMap { dict -> OrmaFriend? in
                            guard let id = dict["id"] as? String,
                                  let displayName = dict["displayName"] as? String,
                                  let username = dict["username"] as? String else { return nil }
                            return OrmaFriend(id: id, displayName: displayName, username: username)
                        }
                        DispatchQueue.main.async {
                            self.friends = loadedFriends
                        }
                    }
                }
            } else {
                // User doesn't exist, create new entry
                let userData: [String: Any] = [
                    "displayName": displayName,
                    "username": self.username,
                    "friends": []
                ]
                userRef.setValue(userData)
            }
        }
    }

    var isLoggedIn: Bool { true }
}
