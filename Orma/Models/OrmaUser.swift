//
//  OrmaUser.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import SwiftUI

class OrmaUser: ObservableObject {
    static let shared = OrmaUser()  // singleton instance
    @Published var user: User? = nil
    private init() {}  // prevent external instantiation

    var isLoggedIn: Bool { user != nil }
}
