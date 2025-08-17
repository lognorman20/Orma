//
//  FeedViewModel.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []

    func fetchAllPosts() {
        PostService().getPosts(completion: { fetchedPosts in
            DispatchQueue.main.async {
                print(
                    "after refreshing the # of posts is \(fetchedPosts.count)"
                )
                self.posts = fetchedPosts.reversed()
            }
        })
    }
    
    func fetchFriendsPosts() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        OrmaUserService().fetchAllFriends(userId: currentUserId) { fetchedFriends in
            PostService().getFriendsPost(friends: fetchedFriends) { friendsPosts in
                DispatchQueue.main.async {
                    print("found \(friendsPosts.count) from frens")
                    self.posts = friendsPosts.reversed()
                }
            }
        }
    }
    
    @MainActor
    func refreshPostsAsync(fetchingFriendsPosts: Bool) async {
        if fetchingFriendsPosts {
            await Task { fetchFriendsPosts() }.value
        } else {
            await Task { fetchAllPosts() }.value
        }
    }
}
