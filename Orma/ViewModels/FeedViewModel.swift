//
//  FeedViewModel.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []

    func refreshPosts() {
        PostService().getPosts(completion: { [weak self] fetchedPosts in
            DispatchQueue.main.async {
                print(
                    "after refreshing the # of posts is \(fetchedPosts.count)"
                )
                self?.posts = fetchedPosts.reversed()
            }
        })
    }
    
    @MainActor
    func refreshPostsAsync() async {
        await Task { refreshPosts() }.value
    }

}
