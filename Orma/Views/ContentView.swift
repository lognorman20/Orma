//
//  ContentView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        if viewModel.isLoggedIn {
            FeedView()
        } else {
            LoginView(viewModel: _viewModel)
        }
    }
}

#Preview {
    ContentView()
}
