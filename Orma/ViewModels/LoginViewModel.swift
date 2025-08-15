//
//  LoginViewModel.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""

    func login() {
        LoginService().login { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    OrmaUser.shared.user = user
                    KeychainService.saveUser(user)
                    if let token = user.refreshToken {
                        KeychainService.saveToken(token)
                    }
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    OrmaUser.shared.user = nil
                }
            }
        }
    }

    func login(email: String, password: String) {
        LoginService().emailLogin(email: email, password: password) { result in
            switch result {
            case .success(let user):
                KeychainService.saveUser(user)
                OrmaUser.shared.user = user
                print("Login successful for UID: \(user.uid)")
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }

    }

    func signOut() {
        LoginService().signOut { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    OrmaUser.shared.user = nil
                    KeychainService.clearAll()
                    print("User signed out successfully.")
                case .failure(let error):
                    print("Sign-out failed: \(error.localizedDescription)")
                }
            }
        }
    }

}
