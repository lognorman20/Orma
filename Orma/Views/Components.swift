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

