//
//  LoginView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        VStack {
            Text("Login")
                .background(in: .buttonBorder)
                .font(.title)
            // TODO: add sign in by email/password
            //            TextField("Username", text: $viewModel.username)
            //            SecureField("Password", text: $viewModel.password)
            GoogleSignInButton(action: loginViewModel.login)
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var isLoggedIn = false
    @Previewable @EnvironmentObject var viewModel: LoginViewModel
    LoginView(loginViewModel: _viewModel)
}
