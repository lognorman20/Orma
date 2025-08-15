//
//  CreatePostViewModel.swift
//  Orma
//
//  Created by Logan Norman on 8/14/25.
//

import SwiftUI

class CreatePostViewModel: ObservableObject {
    func createPost(image: UIImage, reference: String, description: String) async throws {
        try await PostService().createPost(image: image, reference: reference, description: description)
    }
}
