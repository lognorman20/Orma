//
//  FeedView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel

    init(
        viewModel: FeedViewModel = FeedViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            HStack {
                Text("FeedView ya get me")
                NavigationLink(
                    destination: CreatePostView()
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding()

            ScrollView {
                ForEach(viewModel.posts, id: \.id) { post in
                    PostView(post: post)
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
            createdAt: Date().addingTimeInterval(-3600),
            imagePath: "polo",
            verses: [
                BibleClip(
                    id: "v1", book: "Matthew", chapter: 12, startVerse: 8,
                    endVerse: 10)
            ],
            likedBy: ["user123", "user456", "user999"],
            description:
                "This is a sample post description for preview purposes.",
            comments: [
                Comment(
                    id: "c1", creatorId: "user123", postId: "abc123",
                    createdAt: Date().addingTimeInterval(-1800),
                    text: "Great post!", referenceComment: nil),
                Comment(
                    id: "c2", creatorId: "user456", postId: "abc123",
                    createdAt: Date().addingTimeInterval(-1200),
                    text: "Very inspiring.", referenceComment: "c1"),
            ]
        ),
        Post(
            id: "def456",
            creatorId: "user123",
            creatorUsername: "another_user",
            createdAt: Date().addingTimeInterval(-7200),
            imagePath: "log_spread",
            verses: [
                BibleClip(
                    id: "v2", book: "John", chapter: 3, startVerse: 16,
                    endVerse: 16),
                BibleClip(
                    id: "v3", book: "Psalm", chapter: 23, startVerse: 1,
                    endVerse: 4),
            ],
            likedBy: ["user789"],
            description:
                "Another post for the feed preview with multiple verses.",
            comments: [
                Comment(
                    id: "c3", creatorId: "user789", postId: "def456",
                    createdAt: Date().addingTimeInterval(-7000),
                    text: "Love these verses!", referenceComment: nil)
            ]
        ),
        Post(
            id: "ghi789",
            creatorId: "user456",
            creatorUsername: "third_user",
            createdAt: Date().addingTimeInterval(-10800),
            imagePath: "logan_hs",
            verses: [
                BibleClip(
                    id: "v4", book: "Romans", chapter: 8, startVerse: 28,
                    endVerse: 30)
            ],
            likedBy: ["user123", "user789"],
            description:
                "Yet another post in the feed with one powerful verse.",
            comments: []
        ),
        Post(
            id: "jkl012",
            creatorId: "user789",
            creatorUsername: "logan_norman",
            createdAt: Date().addingTimeInterval(-14400),
            imagePath: "polo",
            verses: [
                BibleClip(
                    id: "v5", book: "Genesis", chapter: 1, startVerse: 1,
                    endVerse: 5)
            ],
            likedBy: ["user456", "user999"],
            description:
                "Last sample post for preview with an important creation passage.",
            comments: [
                Comment(
                    id: "c4", creatorId: "user999", postId: "jkl012",
                    createdAt: Date().addingTimeInterval(-14000),
                    text: "Amazing!", referenceComment: nil)
            ]
        ),
    ]

    return vm
}()

#Preview {
    NavigationView {
        FeedView(viewModel: previewVM)
    }
}
