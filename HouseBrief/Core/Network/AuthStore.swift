import Foundation
import Security

/// Token storage in the Keychain. A single shared-secret-signed user token
/// is all the v1 API needs. Keychain avoids the UserDefaults backup-restore
/// quirk and keeps it off iTunes/iCloud backups.
final class AuthStore {
    static let shared = AuthStore()

    private let service = "app.housebrief.auth"
    private let account = "user-token"
    private var cached: String?

    var token: String? {
        if let c = cached { return c }
        guard let data = readKeychain(), let s = String(data: data, encoding: .utf8) else { return nil }
        cached = s
        return s
    }

    func store(token: String) {
        cached = token
        writeKeychain(data: Data(token.utf8))
    }

    func clear() {
        cached = nil
        deleteKeychain()
    }

    // MARK: - Keychain
    private func readKeychain() -> Data? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var out: AnyObject?
        let status = SecItemCopyMatching(q as CFDictionary, &out)
        guard status == errSecSuccess, let d = out as? Data else { return nil }
        return d
    }

    private func writeKeychain(data: Data) {
        deleteKeychain()
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        SecItemAdd(q as CFDictionary, nil)
    }

    private func deleteKeychain() {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(q as CFDictionary)
    }
}
