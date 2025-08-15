//
//  ProfileView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    var body: some View {
        Text("Profile view ya get me")
        Button(action: {}) {
            Text("sign out")
        }
    }

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            KeychainService.clearAll()
            OrmaUser.shared.user = nil
            withAnimation(.easeInOut) {
                OrmaUser.shared.user = nil
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

#Preview {
    ProfileView()
}
