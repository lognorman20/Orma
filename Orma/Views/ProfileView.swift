//
//  ProfileView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @State private var user: OrmaUser = OrmaUser.shared
    @State private var newFriendName: String = ""
    
    var body: some View {
        VStack {
            Text("Profile view ya get me")
            Text(user.firebaseUser.displayName ?? "username not found")
            Button(action: signOut) {
                Text("sign out")
            }
            TextField("add new friend", text: $newFriendName)
            Text("Your friends")
            ScrollView {
                LazyVStack {
                    ForEach(user.friends, id: \.id) { friend in
                        Text(friend.displayName)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            user = OrmaUser.shared
        }
    }

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            KeychainService.clearAll()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

#Preview {
    ProfileView()
}
