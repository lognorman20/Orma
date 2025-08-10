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
    
    func getPosts() {
        
    }
}
