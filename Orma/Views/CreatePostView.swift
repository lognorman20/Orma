//
//  CreatePostView.swift
//  Orma
//
//  Created by Logan Norman on 8/10/25.
//

import PhotosUI
import SwiftUI

struct CreatePostView: View {
    @State var selectedItem: PhotosPickerItem? = nil
    @State var selectedImage: UIImage? = nil
    @State var description: String = ""
    @State var book: String = ""
    @State var chapter: Int = 1
    @State var verseStart: Int = 1
    @State var verseEnd: Int = 1
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Create New Post")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)

                // Photo Selection Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title3)
                            .foregroundColor(.accentColor)

                        Text("Add Photo")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    VStack {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images
                        ) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Select Photo")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)

                                    Text("Choose from your library")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor,
                                        Color.accentColor.opacity(0.8),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(
                                color: Color.accentColor.opacity(0.3),
                                radius: 8, x: 0, y: 4)
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?
                                    .loadTransferable(type: Data.self),
                                    let uiImage = UIImage(data: data)
                                {
                                    selectedImage = uiImage
                                }
                            }
                        }

                        // Preview the selected image
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(20)
                                .padding(.top)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)

                // Bible Verse Picker
                BibleVersePickerView(
                    book: $book,
                    chapter: $chapter,
                    verseStart: $verseStart,
                    verseEnd: $verseEnd
                )

                // Description Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "text.alignleft")
                            .font(.title3)
                            .foregroundColor(.accentColor)

                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        TextField(
                            "What does this verse mean to you? How has it impacted your life?",
                            text: $description,
                            axis: .vertical
                        )
                        .textInputAutocapitalization(.sentences)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .lineLimit(5...10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await submitPost()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.body)
                            Text("Share Post")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.accentColor,
                                    Color.accentColor.opacity(0.8),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(
                            color: Color.accentColor.opacity(0.3), radius: 8,
                            x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .overlay(
            VStack {
                if showToast {
                    Text(toastMessage)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .transition(.opacity)
                        .zIndex(1)
                }
                Spacer()
            }
            .padding(), alignment: .top
        )
    }

    // touches the view model to store the post in firebase
    func submitPost() async {
        guard let image = selectedImage else {
            showToast(
                message:
                    "add a pic lil bro. i know ur chopped but u can still show out for the chuzz (church huzz)"
            )
            return
        }

        let result = BibleData.validateVerse(
            book: book, chapter: chapter, endVerse: verseEnd
        )

        switch result {
        case .success:
            break
        case .failure(let error):
            print("Verse validation failed:", error)
            showToast(message: "nah twin that's not a valid bible verse")
            return
        }

        let reference = BibleData.getReferenceForVerse(
            book: book, chapter: chapter, verseStart: verseStart,
            verseEnd: verseEnd
        )

        do {
            try await CreatePostViewModel().createPost(
                image: image,
                reference: reference,
                description: description
            )
        } catch {
            print("Failed to create post:", error)
            showToast(message: "Failed to create post, try again.")
        }
    }

    func showToast(message: String) {
        withAnimation(.easeIn(duration: 0.2)) {
            toastMessage = message
            showToast = true
        }

        // Hide after 2 seconds with a smooth fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeOut(duration: 0.4)) {
                showToast = false
            }
        }
    }
}

#Preview {
    CreatePostView(
        selectedItem: nil,
        description: "Just did a great bible study this morning!",
        book: "",
        chapter: 1,
        verseStart: 1,
        verseEnd: 1
    )
}
