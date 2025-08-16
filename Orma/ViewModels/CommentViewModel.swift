//
//  CommentViewModel.swift
//  Orma
//
//  Created by Logan Norman on 8/15/25.
//

import Foundation
import SwiftUI

class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []

    func refreshComments(postId: String) {
        PostService().getComments(postId: postId) { [weak self] fetchedComments in
            DispatchQueue.main.async {
                if fetchedComments.isEmpty {
                    print("No comments for postId: \(postId)")
                    self?.comments = []
                } else {
                    print("after refreshing the # of comments is \(fetchedComments.count)")
                    self?.comments = fetchedComments.reversed()
                }
            }
        }
    }

    
    @MainActor
    func refreshCommentsAsync(postId: String) async {
        await Task { refreshComments(postId: postId) }.value
    }

}
