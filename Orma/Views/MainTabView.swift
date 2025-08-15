//
//  MainTabView.swift
//  Orma
//
//  Created by Logan Norman on 8/15/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var body: some View {
        TabView {
            NavigationStack {
                FeedView()
            }
            .tabItem {
                Image(systemName: "house.fill")
            }

            NavigationStack {
                CreatePostView()
            }
            .tabItem {
                Image(systemName: "plus.app.fill")
            }

            NavigationStack {
                ProfileView(loginViewModel: _loginViewModel)
            }
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
            }
        }
        .accentColor(.accentColor)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.systemGroupedBackground
            tabBarAppearance.shadowImage = nil
            tabBarAppearance.shadowColor = nil
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }

    }
}

#Preview {
    MainTabView()
}
