import Foundation

public enum genesisChatTransportEvent: Sendable {
    case health(ok: Bool)
    case tick
    case chat(genesisChatEventPayload)
    case agent(genesisAgentEventPayload)
    case seqGap
}

public protocol genesisChatTransport: Sendable {
    func requestHistory(sessionKey: String) async throws -> genesisChatHistoryPayload
    func sendMessage(
        sessionKey: String,
        message: String,
        thinking: String,
        idempotencyKey: String,
        attachments: [genesisChatAttachmentPayload]) async throws -> genesisChatSendResponse

    func abortRun(sessionKey: String, runId: String) async throws
    func listSessions(limit: Int?) async throws -> genesisChatSessionsListResponse

    func requestHealth(timeoutMs: Int) async throws -> Bool
    func events() -> AsyncStream<genesisChatTransportEvent>

    func setActiveSessionKey(_ sessionKey: String) async throws
}

extension genesisChatTransport {
    public func setActiveSessionKey(_: String) async throws {}

    public func abortRun(sessionKey _: String, runId _: String) async throws {
        throw NSError(
            domain: "genesisChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "chat.abort not supported by this transport"])
    }

    public func listSessions(limit _: Int?) async throws -> genesisChatSessionsListResponse {
        throw NSError(
            domain: "genesisChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "sessions.list not supported by this transport"])
    }
}
