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
    @Published var isLoggedIn = false

    func login() {
        LoginService().login { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.isLoggedIn = true
                    // TODO: look into this being a security issue
                    if let token = user.refreshToken {
                        KeychainService.saveToken(token)
                    }
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    self?.isLoggedIn = false
                }
            }
        }
    }
}
