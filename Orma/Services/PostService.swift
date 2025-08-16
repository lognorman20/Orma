import FirebaseAuth
import FirebaseDatabase
//
//  CreatePostService.swift
//  Orma
//
//  Created by Logan Norman on 8/14/25.
//
import FirebaseStorage
import SwiftUI

class PostService {
    var dbRef: DatabaseReference! = Database.database().reference()
    var storageRef = Storage.storage().reference()

    func likePost(postId: String, userId: String) {
        let postsRef = dbRef.child("posts")
        let query = postsRef.queryOrdered(byChild: "id").queryEqual(
            toValue: postId)

        query.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                print("Post not found: \(postId)")
                return
            }

            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                    let postData = childSnapshot.value as? [String: Any]
                else {
                    continue
                }

                var likedBy = postData["likedBy"] as? [String] ?? []

                if likedBy.contains(userId) {
                    likedBy.removeAll { $0 == userId }
                } else {
                    likedBy.append(userId)
                }

                postsRef.child(childSnapshot.key).child("likedBy").setValue(
                    likedBy
                ) { error, _ in
                    if let error = error {
                        print("Failed to update likes:", error)
                    } else {
                        print("Successfully updated likes for post \(postId)")
                    }
                }
                break  // Only process the first match
            }
        }
    }

    func isLiked(
        postId: String, userId: String, completion: @escaping (Bool) -> Void
    ) {
        let postsRef = dbRef.child("posts")
        let query = postsRef.queryOrdered(byChild: "id").queryEqual(
            toValue: postId)

        query.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                print("Post not found: \(postId)")
                completion(false)
                return
            }

            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                    let postData = childSnapshot.value as? [String: Any]
                else { continue }

                let likedBy = postData["likedBy"] as? [String] ?? []
                completion(likedBy.contains(userId))
                return
            }

            completion(false)
        }
    }

    func getComments(postId: String, completion: @escaping ([Comment]) -> Void)
    {
        let commentsRef = dbRef.child("comments")
            .queryOrdered(byChild: "postId")
            .queryEqual(toValue: postId)

        commentsRef.observeSingleEvent(of: .value) { snapshot in
            var comments: [Comment] = []
            let isoFormatter = ISO8601DateFormatter()

            for case let snap as DataSnapshot in snapshot.children {
                guard let dict = snap.value as? [String: Any],
                    let id = dict["id"] as? String,
                    let creatorId = dict["creatorId"] as? String,
                    let creatorUsername = dict["creatorUsername"] as? String,
                    let postId = dict["postId"] as? String,
                    let createdAtString = dict["createdAt"] as? String,
                    let createdAt = isoFormatter.date(from: createdAtString),
                    let text = dict["text"] as? String
                else {
                    print("Skipping: invalid data in snapshot \(snap.key)")
                    continue
                }

                let referenceCommentId = dict["referenceCommentId"] as? String

                let comment = Comment(
                    id: id,
                    creatorId: creatorId,
                    creatorUsername: creatorUsername,
                    postId: postId,
                    createdAt: createdAt,
                    text: text,
                    referenceCommentId: referenceCommentId
                )

                comments.append(comment)
            }

            print("Got \(comments.count) comments for postId: \(postId)")
            completion(comments)
        }
    }

    func getCommentById(commentId: String) async throws -> Comment? {
        try await withCheckedThrowingContinuation { continuation in
            let query = dbRef.child("comments").queryOrdered(byChild: "id").queryEqual(toValue: commentId)
            query.observeSingleEvent(of: .value) { snapshot in
                let iso = ISO8601DateFormatter()
                for case let snap as DataSnapshot in snapshot.children {
                    guard let dict = snap.value as? [String: Any],
                          let id = dict["id"] as? String,
                          let creatorId = dict["creatorId"] as? String,
                          let creatorUsername = dict["creatorUsername"] as? String,
                          let postId = dict["postId"] as? String,
                          let createdAtString = dict["createdAt"] as? String,
                          let createdAt = iso.date(from: createdAtString),
                          let text = dict["text"] as? String else { continue }
                    let referenceCommentId = (dict["referenceCommentId"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                    continuation.resume(returning: Comment(id: id, creatorId: creatorId, creatorUsername: creatorUsername, postId: postId, createdAt: createdAt, text: text, referenceCommentId: referenceCommentId))
                    return
                }
                continuation.resume(returning: nil)
            }
        }
    }
    
    func getPosts(completion: @escaping ([Post]) -> Void) {
        let postsRef = dbRef.child("posts")
        postsRef.observeSingleEvent(of: .value) { snapshot in
            var posts: [Post] = []
            let isoFormatter = ISO8601DateFormatter()

            for case let snap as DataSnapshot in snapshot.children {
                guard let dict = snap.value as? [String: Any] else {
                    print("Skipping: not a dictionary for snapshot \(snap.key)")
                    continue
                }

                guard let id = dict["id"] as? String,
                    let creatorId = dict["creatorId"] as? String,
                    let creatorUsername = dict["creatorUsername"] as? String,
                    let createdAtString = dict["createdAt"] as? String,
                    let createdAt = isoFormatter.date(from: createdAtString),
                    let imagePath = dict["imagePath"] as? String,
                    let reference = dict["reference"] as? String,
                    let description = dict["description"] as? String
                else {
                    print(
                        "Skipping: missing required fields in snapshot \(snap.key): \(dict)"
                    )
                    continue
                }

                let likedBy = dict["likedBy"] as? [String] ?? []
                let commentsData = dict["comments"] as? [[String: Any]] ?? []
                let comments: [Comment] = commentsData.compactMap {
                    commentDict in
                    try? JSONDecoder().decode(
                        Comment.self,
                        from: JSONSerialization.data(
                            withJSONObject: commentDict))
                }

                let post = Post(
                    id: id,
                    creatorId: creatorId,
                    creatorUsername: creatorUsername,
                    createdAt: createdAt,
                    imagePath: imagePath,
                    reference: reference,
                    likedBy: likedBy,
                    description: description,
                    comments: comments
                )

                posts.append(post)
            }

            print("Got \(posts.count) posts total")
            completion(posts)
        }
    }

    func getImage(
        from urlString: String, completion: @escaping (UIImage?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image:", error)
                completion(nil)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }

    func createComment(
        postId: String,
        text: String,
        referenceCommentId: String? = nil
    ) async throws {
        guard let currentUser = OrmaUser.shared.firebaseUser else { return }

        let commentId = UUID().uuidString
        let commentData: [String: Any] = [
            "id": commentId,
            "creatorId": currentUser.uid,
            "creatorUsername": currentUser.displayName ?? "Unknown",
            "postId": postId,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "text": text,
            "referenceCommentId": referenceCommentId ?? "",
        ]

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            dbRef.child("comments").childByAutoId().setValue(commentData) {
                error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        print("Successfully created comment for post \(postId)")
    }

    func createPost(image: UIImage, reference: String, description: String)
        async throws
    {
        guard let currentUser = OrmaUser.shared.firebaseUser else { return }
        // store the image in Cloud Storage
        let imagePath = try await uploadImage(image, for: currentUser)

        // store the post in Firestore with currentUser info
        let postId = UUID().uuidString
        let postData: [String: Any] = [
            "id": postId,
            "creatorId": currentUser.uid,
            "creatorUsername": currentUser.displayName ?? "Unknown",
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "imagePath": imagePath.absoluteString,
            "reference": reference,
            "description": description,
        ]
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            dbRef.child("posts").childByAutoId().setValue(postData) {
                error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        print("Successfully posted!")
    }

    func uploadImage(_ image: UIImage, for user: User) async throws -> URL {
        guard
            // TODO: this doesnt really do anything...
            let (imageData, fileExtension) = {
                if let jpegData = image.jpegData(compressionQuality: 0.8) {
                    return (jpegData, "jpg")
                }
                if let pngData = image.pngData() { return (pngData, "png") }
                return nil
            }()
        else {
            throw NSError(
                domain: "UploadError", code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unsupported image format"
                ])
        }

        let filename = "\(user.uid)/\(UUID().uuidString).\(fileExtension)"
        let imageRef = storageRef.child(filename)

        let _ = try await imageRef.putDataAsync(imageData, metadata: nil)
        return try await imageRef.downloadURL()
    }
}
