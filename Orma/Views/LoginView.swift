//
//  LoginView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.15, blue: 0.3),
                        Color(red: 0.2, green: 0.25, blue: 0.4),
                        Color(red: 0.15, green: 0.2, blue: 0.35)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating orbs for visual interest
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: -100, y: -200)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(Color.purple.opacity(0.08))
                    .frame(width: 150, height: 150)
                    .blur(radius: 30)
                    .offset(x: 120, y: 300)
                    .scaleEffect(isAnimating ? 0.9 : 1.1)
                    .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Logo and Title Section
                    VStack(spacing: 16) {
                        // Logo placeholder - you can replace with actual logo
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "book.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Text("Orma")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [.white, Color(white: 0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        
                        Text("Track your spiritual journey")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(white: 0.7))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Login Section
                    VStack(spacing: 24) {
                        Text("Welcome back")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Continue your Bible study streak")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(white: 0.6))
                            .multilineTextAlignment(.center)
                        
                        // Google Sign In Button
                        Button(action: {
                            loginViewModel.login()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.4, blue: 0.8),
                                            Color(red: 0.3, green: 0.2, blue: 0.7)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(isAnimating ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                            
                            Text("or")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                        }
                        
                        // Email/Password Section (Currently disabled but styled)
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .frame(width: 20)
                                Text("Email sign-in coming soon")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.6))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    @Previewable @EnvironmentObject var viewModel: LoginViewModel
    LoginView(loginViewModel: _viewModel)
}
