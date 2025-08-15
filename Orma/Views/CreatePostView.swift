//
//  CreatePostView.swift
//  Orma
//
//  Created by Logan Norman on 8/10/25.
//

import PhotosUI
import SwiftUI

struct CreatePostView: View {
    @State var selectedItem: PhotosPickerItem?
    @Binding var description: String

    var body: some View {
        VStack {
            Text("Create New Post")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                Text("Select a photo")
            }
            .padding()
            
            // TODO: add a input sectionfor the verses

            TextField(
                "Your description goes here",
                text: $description
            )
            .textInputAutocapitalization(.sentences)
            .border(.secondary)
        }
    }
    
    // touches the view model to store the post in firebase
    func submitPost() {
        
    }
}

#Preview {
    CreatePostView(description: .constant("Just did a great bible study this morning!"))
}
