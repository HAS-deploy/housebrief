import Foundation

enum APIError: LocalizedError {
    case badURL
    case network(Error)
    case http(status: Int, message: String)
    case decode(Error)
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .badURL: return "Bad URL"
        case .network(let e): return "Network: \(e.localizedDescription)"
        case .http(let s, let m): return "HTTP \(s): \(m)"
        case .decode(let e): return "Decode: \(e.localizedDescription)"
        case .notAuthenticated: return "Please sign in"
        }
    }
}

/// Thin typed client for housebrief-api. Stateless — token pulled from
/// `AuthStore.shared` at request time so sign-out is immediate.
@MainActor
final class APIClient {
    static let shared = APIClient()

    // Swap via Info.plist HB_API_BASE or hard-code for dev.
    private let baseURL: URL = {
        if let s = Bundle.main.object(forInfoDictionaryKey: "HB_API_BASE") as? String,
           let u = URL(string: s) {
            return u
        }
        return URL(string: "https://v5h4vig89k.execute-api.us-east-1.amazonaws.com")!
    }()

    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 30
        c.waitsForConnectivity = true
        return URLSession(configuration: c)
    }()

    // MARK: - state check
    struct StateCheckResponse: Decodable {
        let stateCode: String
        let availability: String
        let canSubmit: Bool
        let disclosures: [String]
        let universalDisclosures: [String]
    }
    func stateCheck(stateCode: String) async throws -> StateCheckResponse {
        try await post("/v1/state-check", body: ["stateCode": stateCode], authed: false)
    }

    // MARK: - submit
    struct SubmitResponse: Decodable {
        let submissionId: String
        let status: String
        let token: String?
        let userId: String
    }
    struct SubmitBody: Encodable {
        var contactEmail: String?
        var contactPhone: String?
        var stateCode: String
        var addressLine1: String
        var addressLine2: String?
        var city: String
        var zip: String
        var propertyType: String
        var yearBuilt: Int?
        var beds: Int?
        var baths: Double?
        var sqftEst: Int?
        var conditionScore: Int
        var repairNotes: String
        var occupancy: String
        var timeline: String
        var askingAmountCents: Int?
        var flagInherited: Bool
        var flagProbate: Bool
        var flagBehindOnPayments: Bool
        var flagTaxOrLien: Bool
        var flagCodeViolation: Bool
    }
    func submit(_ body: SubmitBody) async throws -> SubmitResponse {
        try await post("/v1/submissions", body: body, authed: true)
    }

    // MARK: - list + detail
    struct ListResponse: Decodable {
        struct Row: Decodable, Identifiable {
            let id: String
            let status: String
            let stateCode: String
            let addressShort: String
            let createdAt: String
        }
        let submissions: [Row]
    }
    func listMine() async throws -> ListResponse {
        try await get("/v1/submissions/mine")
    }

    struct DetailResponse: Decodable { let submission: [String: AnyCodable] }
    func getOne(id: String) async throws -> DetailResponse {
        try await get("/v1/submissions/\(id)")
    }

    // MARK: - account deletion
    struct DeleteResponse: Decodable { let deleted: Bool }
    func deleteAccount() async throws -> DeleteResponse {
        try await delete("/v1/account")
    }

    // MARK: - HTTP internals
    private func get<T: Decodable>(_ path: String) async throws -> T {
        try await send(method: "GET", path: path, body: Optional<String>.none, authed: true)
    }
    private func delete<T: Decodable>(_ path: String) async throws -> T {
        try await send(method: "DELETE", path: path, body: Optional<String>.none, authed: true)
    }
    private func post<T: Decodable, B: Encodable>(_ path: String, body: B, authed: Bool) async throws -> T {
        try await send(method: "POST", path: path, body: body, authed: authed)
    }

    private func send<T: Decodable, B: Encodable>(method: String, path: String, body: B?, authed: Bool) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.badURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authed, let tok = AuthStore.shared.token {
            req.setValue("Bearer \(tok)", forHTTPHeaderField: "Authorization")
        }
        if let b = body {
            req.httpBody = try JSONEncoder().encode(b)
        }

        let (data, resp): (Data, URLResponse)
        do {
            (data, resp) = try await session.data(for: req)
        } catch {
            throw APIError.network(error)
        }
        guard let http = resp as? HTTPURLResponse else {
            throw APIError.http(status: -1, message: "Unknown response type")
        }
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? ""
            throw APIError.http(status: http.statusCode, message: msg)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decode(error)
        }
    }
}

/// Lightweight any-JSON decoder for responses where a flexible field is OK.
struct AnyCodable: Codable {
    let value: Any?
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { value = nil; return }
        if let v = try? c.decode(Bool.self) { value = v; return }
        if let v = try? c.decode(Int.self) { value = v; return }
        if let v = try? c.decode(Double.self) { value = v; return }
        if let v = try? c.decode(String.self) { value = v; return }
        if let v = try? c.decode([AnyCodable].self) { value = v.map(\.value); return }
        if let v = try? c.decode([String: AnyCodable].self) { value = v.mapValues(\.value); return }
        value = nil
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case nil: try c.encodeNil()
        case let v as Bool: try c.encode(v)
        case let v as Int: try c.encode(v)
        case let v as Double: try c.encode(v)
        case let v as String: try c.encode(v)
        default: try c.encodeNil()
        }
    }
}
