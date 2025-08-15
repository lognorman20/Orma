//
//  KeychainService.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import FirebaseAuth
import Security

class KeychainService {
    static func saveUser(_ user: User) {
        guard let uidData = user.uid.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "firebaseUserUID",
            kSecValueData as String: uidData,
        ]

        // remove old entry if it exists
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("Error saving user to keychain: \(status)")
        }
    }

    static func signOut() {

    }

    static func getUserUID() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "firebaseUserUID",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data,
            let uid = String(data: data, encoding: .utf8)
        {
            return uid
        }

        return nil
    }

    static func saveToken(_ token: String) {
        let tokenData = Data(token.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "userToken",
            kSecValueData: tokenData,
        ]

        SecItemDelete(query as CFDictionary)  // Delete old item if exists
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
            kSecMatchLimit: kSecMatchLimitOne,
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess,
            let data = dataTypeRef as? Data,
            let token = String(data: data, encoding: .utf8)
        {
            return token
        }
        return nil
    }

    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userToken",
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func deleteUserUID() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "firebaseUserUID",
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func clearAll() {
        deleteUserUID()
        deleteToken()
    }
}
