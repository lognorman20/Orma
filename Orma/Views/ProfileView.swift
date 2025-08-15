//
//  ProfileView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        Text("Profile view ya get me")
        Button(action: {
            print("tryna log out rn")
            loginViewModel.signOut()
        }) {
            Text("sign out")
        }
    }
}

#Preview {
    ProfileView()
}
