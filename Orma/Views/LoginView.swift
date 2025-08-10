//
//  LoginView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Text("Login")
                .background(in: .buttonBorder)
                .font(.title)
            TextField("Username", text: $viewModel.username)
            SecureField("Password", text: $viewModel.password)
            GoogleSignInButton(action: viewModel.login)
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var isLoggedIn = false
    @Previewable @StateObject var viewModel: LoginViewModel = LoginViewModel()
    LoginView(viewModel: viewModel)
}
