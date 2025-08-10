//
//  FeedView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel

    init(viewModel: FeedViewModel = FeedViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Text("FeedView ya get me")
            List {
                ForEach(viewModel.posts, id: \.id) { post in
                    VStack(alignment: .leading) {
                        PostView(post: post)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.getPosts()
        }
    }
}

private let previewVM: FeedViewModel = {
    let vm = FeedViewModel()
    vm.posts = [
        Post(
            id: "abc123",
            creatorId: "user789",
            creatorUsername: "logan_norman",
            createdAt: Date(),
            imagePath: "polo",
            description: "This is a sample post description for preview purposes.",
            comments: []
        ),
        Post(
            id: "def456",
            creatorId: "user123",
            creatorUsername: "another_user",
            createdAt: Date(),
            imagePath: "log_spread",
            description: "Another post for the feed preview.",
            comments: []
        ),
        Post(
            id: "def456",
            creatorId: "user123",
            creatorUsername: "another_user",
            createdAt: Date(),
            imagePath: "log_spread",
            description: "Another post for the feed preview.",
            comments: []
        ),
        Post(
            id: "def456",
            creatorId: "user123",
            creatorUsername: "another_user",
            createdAt: Date(),
            imagePath: "log_spread",
            description: "Another post for the feed preview.",
            comments: []
        ),
    ]
    return vm
}()

#Preview {
    FeedView(viewModel: previewVM)
}
