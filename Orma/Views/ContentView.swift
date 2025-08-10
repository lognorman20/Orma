//
//  ContentView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        if loginViewModel.isLoggedIn {
            FeedView()
        } else {
            LoginView(viewModel: loginViewModel)
        }
    }
}

#Preview {
    ContentView()
}
