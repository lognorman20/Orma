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
