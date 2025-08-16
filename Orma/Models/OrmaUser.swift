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
    let id: String
    let displayName: String
    var username: String
}

class OrmaUser: ObservableObject {
    private static var dbRef: DatabaseReference = Database.database().reference()

    static let shared = OrmaUser() // always exists

    @Published var firebaseUser: User? = nil
    @Published var username: String = ""
    @Published var friends: [OrmaFriend] = []

    let ormaUserId: String = ""
    var displayName: String = ""

    private init() {
        if let currentUser = Auth.auth().currentUser {
            self.firebaseUser = currentUser
            self.displayName = currentUser.displayName ?? "User"
            self.username = currentUser.displayName?.components(separatedBy: CharacterSet.alphanumerics.inverted).joined() ?? "User"

            let userRef = Self.dbRef.child("users").child(currentUser.uid)
            userRef.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
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
                    let userData: [String: Any] = [
                        "displayName": self.displayName,
                        "username": self.username,
                        "friends": []
                    ]
                    userRef.setValue(userData)
                }
            }
        }
    }

    var isLoggedIn: Bool { firebaseUser != nil }
}
