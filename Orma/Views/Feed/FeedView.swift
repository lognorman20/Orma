//
//  FeedView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject var feedViewModel: FeedViewModel

    init(viewModel: FeedViewModel = FeedViewModel()) {
        _feedViewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(feedViewModel.posts, id: \.id) { post in
                    PostView(post: post)
                }
            }
        }
        .refreshable {
            await feedViewModel.refreshPostsAsync()
        }
        .onAppear {
            feedViewModel.refreshPosts()
        }
    }
}
