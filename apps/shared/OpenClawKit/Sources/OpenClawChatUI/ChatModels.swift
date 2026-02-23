import genesisKit
import Foundation

// NOTE: keep this file lightweight; decode must be resilient to varying transcript formats.

#if canImport(AppKit)
import AppKit

public typealias genesisPlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit

public typealias genesisPlatformImage = UIImage
#endif

public struct genesisChatUsageCost: Codable, Hashable, Sendable {
    public let input: Double?
    public let output: Double?
    public let cacheRead: Double?
    public let cacheWrite: Double?
    public let total: Double?
}

public struct genesisChatUsage: Codable, Hashable, Sendable {
    public let input: Int?
    public let output: Int?
    public let cacheRead: Int?
    public let cacheWrite: Int?
    public let cost: genesisChatUsageCost?
    public let total: Int?

    enum CodingKeys: String, CodingKey {
        case input
        case output
        case cacheRead
        case cacheWrite
        case cost
        case total
        case totalTokens
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.input = try container.decodeIfPresent(Int.self, forKey: .input)
        self.output = try container.decodeIfPresent(Int.self, forKey: .output)
        self.cacheRead = try container.decodeIfPresent(Int.self, forKey: .cacheRead)
        self.cacheWrite = try container.decodeIfPresent(Int.self, forKey: .cacheWrite)
        self.cost = try container.decodeIfPresent(genesisChatUsageCost.self, forKey: .cost)
        self.total =
            try container.decodeIfPresent(Int.self, forKey: .total) ??
            container.decodeIfPresent(Int.self, forKey: .totalTokens)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.input, forKey: .input)
        try container.encodeIfPresent(self.output, forKey: .output)
        try container.encodeIfPresent(self.cacheRead, forKey: .cacheRead)
        try container.encodeIfPresent(self.cacheWrite, forKey: .cacheWrite)
        try container.encodeIfPresent(self.cost, forKey: .cost)
        try container.encodeIfPresent(self.total, forKey: .total)
    }
}

public struct genesisChatMessageContent: Codable, Hashable, Sendable {
    public let type: String?
    public let text: String?
    public let thinking: String?
    public let thinkingSignature: String?
    public let mimeType: String?
    public let fileName: String?
    public let content: AnyCodable?

    // Tool-call fields (when `type == "toolCall"` or similar)
    public let id: String?
    public let name: String?
    public let arguments: AnyCodable?

    public init(
        type: String?,
        text: String?,
        thinking: String? = nil,
        thinkingSignature: String? = nil,
        mimeType: String?,
        fileName: String?,
        content: AnyCodable?,
        id: String? = nil,
        name: String? = nil,
        arguments: AnyCodable? = nil)
    {
        self.type = type
        self.text = text
        self.thinking = thinking
        self.thinkingSignature = thinkingSignature
        self.mimeType = mimeType
        self.fileName = fileName
        self.content = content
        self.id = id
        self.name = name
        self.arguments = arguments
    }

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case thinking
        case thinkingSignature
        case mimeType
        case fileName
        case content
        case id
        case name
        case arguments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.thinking = try container.decodeIfPresent(String.self, forKey: .thinking)
        self.thinkingSignature = try container.decodeIfPresent(String.self, forKey: .thinkingSignature)
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        self.fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.arguments = try container.decodeIfPresent(AnyCodable.self, forKey: .arguments)

        if let any = try container.decodeIfPresent(AnyCodable.self, forKey: .content) {
            self.content = any
        } else if let str = try container.decodeIfPresent(String.self, forKey: .content) {
            self.content = AnyCodable(str)
        } else {
            self.content = nil
        }
    }
}

public struct genesisChatMessage: Codable, Identifiable, Sendable {
    public var id: UUID = .init()
    public let role: String
    public let content: [genesisChatMessageContent]
    public let timestamp: Double?
    public let toolCallId: String?
    public let toolName: String?
    public let usage: genesisChatUsage?
    public let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case timestamp
        case toolCallId
        case tool_call_id
        case toolName
        case tool_name
        case usage
        case stopReason
    }

    public init(
        id: UUID = .init(),
        role: String,
        content: [genesisChatMessageContent],
        timestamp: Double?,
        toolCallId: String? = nil,
        toolName: String? = nil,
        usage: genesisChatUsage? = nil,
        stopReason: String? = nil)
    {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.toolCallId = toolCallId
        self.toolName = toolName
        self.usage = usage
        self.stopReason = stopReason
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(String.self, forKey: .role)
        self.timestamp = try container.decodeIfPresent(Double.self, forKey: .timestamp)
        self.toolCallId =
            try container.decodeIfPresent(String.self, forKey: .toolCallId) ??
            container.decodeIfPresent(String.self, forKey: .tool_call_id)
        self.toolName =
            try container.decodeIfPresent(String.self, forKey: .toolName) ??
            container.decodeIfPresent(String.self, forKey: .tool_name)
        self.usage = try container.decodeIfPresent(genesisChatUsage.self, forKey: .usage)
        self.stopReason = try container.decodeIfPresent(String.self, forKey: .stopReason)

        if let decoded = try? container.decode([genesisChatMessageContent].self, forKey: .content) {
            self.content = decoded
            return
        }

        // Some session log formats store `content` as a plain string.
        if let text = try? container.decode(String.self, forKey: .content) {
            self.content = [
                genesisChatMessageContent(
                    type: "text",
                    text: text,
                    thinking: nil,
                    thinkingSignature: nil,
                    mimeType: nil,
                    fileName: nil,
                    content: nil,
                    id: nil,
                    name: nil,
                    arguments: nil),
            ]
            return
        }

        self.content = []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.role, forKey: .role)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.toolCallId, forKey: .toolCallId)
        try container.encodeIfPresent(self.toolName, forKey: .toolName)
        try container.encodeIfPresent(self.usage, forKey: .usage)
        try container.encodeIfPresent(self.stopReason, forKey: .stopReason)
        try container.encode(self.content, forKey: .content)
    }
}

public struct genesisChatHistoryPayload: Codable, Sendable {
    public let sessionKey: String
    public let sessionId: String?
    public let messages: [AnyCodable]?
    public let thinkingLevel: String?
}

public struct genesisSessionPreviewItem: Codable, Hashable, Sendable {
    public let role: String
    public let text: String
}

public struct genesisSessionPreviewEntry: Codable, Sendable {
    public let key: String
    public let status: String
    public let items: [genesisSessionPreviewItem]
}

public struct genesisSessionsPreviewPayload: Codable, Sendable {
    public let ts: Int
    public let previews: [genesisSessionPreviewEntry]

    public init(ts: Int, previews: [genesisSessionPreviewEntry]) {
        self.ts = ts
        self.previews = previews
    }
}

public struct genesisChatSendResponse: Codable, Sendable {
    public let runId: String
    public let status: String
}

public struct genesisChatEventPayload: Codable, Sendable {
    public let runId: String?
    public let sessionKey: String?
    public let state: String?
    public let message: AnyCodable?
    public let errorMessage: String?
}

public struct genesisAgentEventPayload: Codable, Sendable, Identifiable {
    public var id: String { "\(self.runId)-\(self.seq ?? -1)" }
    public let runId: String
    public let seq: Int?
    public let stream: String
    public let ts: Int?
    public let data: [String: AnyCodable]
}

public struct genesisChatPendingToolCall: Identifiable, Hashable, Sendable {
    public var id: String { self.toolCallId }
    public let toolCallId: String
    public let name: String
    public let args: AnyCodable?
    public let startedAt: Double?
    public let isError: Bool?
}

public struct genesisGatewayHealthOK: Codable, Sendable {
    public let ok: Bool?
}

public struct genesisPendingAttachment: Identifiable {
    public let id = UUID()
    public let url: URL?
    public let data: Data
    public let fileName: String
    public let mimeType: String
    public let type: String
    public let preview: genesisPlatformImage?

    public init(
        url: URL?,
        data: Data,
        fileName: String,
        mimeType: String,
        type: String = "file",
        preview: genesisPlatformImage?)
    {
        self.url = url
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
        self.type = type
        self.preview = preview
    }
}

public struct genesisChatAttachmentPayload: Codable, Sendable, Hashable {
    public let type: String
    public let mimeType: String
    public let fileName: String
    public let content: String

    public init(type: String, mimeType: String, fileName: String, content: String) {
        self.type = type
        self.mimeType = mimeType
        self.fileName = fileName
        self.content = content
    }
}
