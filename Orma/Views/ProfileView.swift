//
//  ProfileView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @State private var user: OrmaUser = OrmaUser.shared
    @State private var newFriendName: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text(initials(from: user.displayName))
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text(user.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            // Sign Out Button
                            Button(action: signOut) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.title3)
                                    
                                    Text("Sign Out")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.red.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.red.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Add Friend Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            Text("Add Friend")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            TextField("Enter friend's name", text: $newFriendName)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addFriend()
                                }
                            
                            Button(action: addFriend) {
                                Text("Add")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(newFriendName.isEmpty ? Color.gray : Color.blue)
                                    )
                            }
                            .disabled(newFriendName.isEmpty)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                    // Friends Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.green)
                                .font(.title3)
                            
                            Text("Your Friends")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(user.friends.count)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.green.opacity(0.1))
                                )
                        }
                        
                        if user.friends.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "person.2.slash")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary.opacity(0.5))
                                
                                Text("No friends added yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add your first friend above!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(user.friends, id: \.id) { friend in
                                    HStack(spacing: 12) {
                                        // Friend Avatar
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.purple, .pink],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 40, height: 40)
                                            
                                            Text(initials(from: friend.displayName))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text(friend.displayName)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.clear)
                                    )
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGray6),
                        Color(.systemGray5).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            user = OrmaUser.shared
        }
    }
    
    private func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first?.uppercased() }
        return initials.joined()
    }
    
    private func addFriend() {
        guard !newFriendName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add the friend to user.friends array
        // This would typically involve calling a service or updating the model
        newFriendName = ""
    }

    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            KeychainService.clearAll()
            OrmaUser.shared.firebaseUser = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

#Preview {
    ProfileView()
}
