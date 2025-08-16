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
                    let ormaUser = OrmaUser.shared
                    ormaUser.firebaseUser = user
                    if let displayName = user.displayName, !displayName.isEmpty {
                        ormaUser.displayName = displayName
                        ormaUser.username = displayName.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
                    }

                    KeychainService.saveUser(user)
                    if let token = user.refreshToken {
                        KeychainService.saveToken(token)
                    }

                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
