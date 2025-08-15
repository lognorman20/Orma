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
        NavigationView {
            if viewModel.isLoggedIn {
                FeedView()
            } else {
                LoginView(viewModel: _viewModel)
            }
        }
    }
}

#Preview {
    @Previewable @EnvironmentObject var viewModel: LoginViewModel
    ContentView(viewModel: _viewModel)
}
