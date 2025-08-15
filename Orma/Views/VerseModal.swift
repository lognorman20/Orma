//
//  VerseModal.swift
//  Orma
//
//  Created by Logan Norman on 8/15/25.
//

import FirebaseDatabase
import SwiftUI

struct VerseModal: View {
    @Binding var isPresented: Bool
    @State private var verseText: String = ""
    let reference: String

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with reference
                VStack(spacing: 12) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)

                    Text(reference)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)

                // Verse content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(verseText)
                            .font(.title3)
                            .fontWeight(.medium)
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 24)

                        Color.clear.frame(height: 20)
                    }
                }
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: .topLeading)

                // Bottom action area
                VStack(spacing: 16) {
                    Divider()

                    HStack(spacing: 12) {
                        // Share button
                        Button(action: {
                            // Add share functionality here
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Share")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Close button
                        Button("Done") {
                            isPresented = false
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(20)
        .onAppear {
            getVerse(reference: reference)
        }
    }

    func getVerse(reference: String) {
        let dbRef = Database.database().reference()

        dbRef.child("esvApiKey").observeSingleEvent(of: .value) { snapshot in
            guard let apiKey = snapshot.value as? String else {
                print("Failed to get API key")
                return
            }

            // Encode the reference for the URL
            let encodedReference =
                reference.replacingOccurrences(of: " ", with: "+")
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ?? reference

            // Build the URL request with additional parameters
            let urlString =
                "https://api.esv.org/v3/passage/text/?"
                + "q=\(encodedReference)" + "&include-passage-references=false"
                + "&include-footnotes=false" + "&include-verse-numbers=true"
                + "&indent-paragraphs=0"

            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.setValue(
                "Token \(apiKey)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    print("Request failed:", error ?? "")
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data)
                    as? [String: Any],
                    let passages = json["passages"] as? [String],
                    let firstPassage = passages.first
                {
                    verseText = firstPassage
                } else {
                    print("Failed to parse response")
                }
            }.resume()
        }
    }

}

struct VerseModal_Previews: PreviewProvider {
    @State static var showModal = true

    static var previews: some View {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
            .sheet(isPresented: $showModal) {
                VerseModal(
                    isPresented: $showModal,
                    reference: "John 3:16-17"
                )
            }
    }
}
