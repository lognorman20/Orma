//
//  KeychainService.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import Foundation
import Security

class KeychainService {
    static func saveToken(_ token: String) {
        let tokenData = Data(token.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "userToken",
            kSecValueData: tokenData
        ]

        SecItemDelete(query as CFDictionary) // Delete old item if exists
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("Token saved successfully")
        } else {
            print("Failed to save token: \(status)")
        }
    }

    static func getToken() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "userToken",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }
}
