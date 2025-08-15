//
//  ContentView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @ObservedObject var ormaUser = OrmaUser.shared
    
    var body: some View {
        NavigationView {
            if ormaUser.user != nil {
                MainTabView()
            } else {
                LoginView(loginViewModel: _viewModel)
            }
        }
    }
}

#Preview {
    @Previewable @EnvironmentObject var viewModel: LoginViewModel
    ContentView(viewModel: _viewModel)
}
