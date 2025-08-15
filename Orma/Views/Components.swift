//
//  Components.swift
//  Orma
//
//  Created by Logan Norman on 8/10/25.
//

import SwiftUI

struct AddPostButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

struct GradientCircleButton: ButtonStyle {
    var gradient: LinearGradient
    var isToggle: Bool = false
    @Binding var isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .fill(
                    isToggle
                        ? (isActive ? gradient : LinearGradient(
                            colors: [.gray.opacity(0.2), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing))
                        : gradient
                )
                .frame(width: 28, height: 28)
            
            configuration.label
                .foregroundColor(isToggle && !isActive ? .red : .white)
        }
        .scaleEffect(configuration.isPressed || (isToggle && isActive) ? 1.1 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed || isActive)
    }
}

public struct IntroTopView: View {
    @State public var isAnimating: Bool
    
    public var body: some View {
        // App Logo and Title Section
        VStack(spacing: 16) {
            // Logo placeholder - you can replace with actual logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue, Color.purple,
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: .blue.opacity(0.3), radius: 20, x: 0,
                        y: 10)

                Image(systemName: "book.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 2).repeatForever(
                    autoreverses: true), value: isAnimating)

            Text("Orma")
                .font(
                    .system(
                        size: 42, weight: .bold, design: .rounded)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white, Color(white: 0.8),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))

            Text("Track your spiritual journey")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.7))
                .multilineTextAlignment(.center)
        }

    }
}

public struct IntroDividerView: View {
    public var body: some View {
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
    }
}

public struct EmailPasswordView: View {
    @State public var email: String
    @State public var password: String
    @State public var loginError: String?
    
    public init(email: String = "", password: String = "", loginError: String? = nil) {
        self._email = State(initialValue: email)
        self._password = State(initialValue: password)
        self._loginError = State(initialValue: loginError)
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            EmailField(email: $email)
            PasswordField(password: $password)
            
            if let error = loginError {
                LoginErrorView(error: error)
            }
            
            EmailSignInButton(email: email, password: password) { errorMessage in
                self.loginError = errorMessage
            }
        }
        .padding(.horizontal, 32)
    }
}

private struct EmailField: View {
    @Binding var email: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "envelope")
                .foregroundColor(isFocused ? .blue : Color.white.opacity(0.6))
                .frame(width: 20, height: 20)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField("", text: $email, prompt: Text("Email address").foregroundColor(Color.white.opacity(0.5)))
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .accentColor(.blue)
                .focused($isFocused)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isFocused ? 0.12 : 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isFocused ? Color.blue.opacity(0.4) : Color.white.opacity(0.15),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .shadow(
                    color: isFocused ? Color.blue.opacity(0.1) : Color.clear,
                    radius: isFocused ? 8 : 0,
                    x: 0,
                    y: isFocused ? 2 : 0
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

private struct PasswordField: View {
    @Binding var password: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "lock")
                .foregroundColor(isFocused ? .blue : Color.white.opacity(0.6))
                .frame(width: 20, height: 20)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            SecureField("", text: $password, prompt: Text("Password").foregroundColor(Color.white.opacity(0.5)))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .accentColor(.blue)
                .focused($isFocused)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isFocused ? 0.12 : 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isFocused ? Color.blue.opacity(0.4) : Color.white.opacity(0.15),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .shadow(
                    color: isFocused ? Color.blue.opacity(0.1) : Color.clear,
                    radius: isFocused ? 8 : 0,
                    x: 0,
                    y: isFocused ? 2 : 0
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

private struct LoginErrorView: View {
    let error: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14))
            
            Text(error)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

private struct EmailSignInButton: View {
    let email: String
    let password: String
    let onError: (String) -> Void
    
    var body: some View {
        Button(action: signIn) {
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Sign In with Email")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.25, green: 0.45, blue: 0.75),
                                Color(red: 0.35, green: 0.25, blue: 0.65)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.blue.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(email.isEmpty || password.isEmpty)
        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
    }
    
    private func signIn() {
        LoginService().emailLogin(email: email, password: password) { result in
            switch result {
            case .success(let user):
                KeychainService.saveUser(user)
                OrmaUser.shared.user = user
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
}

#Preview {
    
}
