//
//  KeychainHelper.swift
//  ReToU
//
//  앱 잠금 비밀번호를 Keychain에 안전하게 저장
//

import Foundation
import Security

enum KeychainHelper {
    private static let service = "com.dean.ReToU"
    private static let pinAccount = "app_lock_pin"

    // MARK: - PIN

    /// 6자리 비밀번호 저장 (기존 값 덮어씀)
    @discardableResult
    static func savePin(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        deletePin()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: pinAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    /// 저장된 비밀번호 읽기
    static func loadPin() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: pinAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 비밀번호 삭제
    @discardableResult
    static func deletePin() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: pinAccount
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    static var hasPin: Bool {
        loadPin() != nil
    }
}
