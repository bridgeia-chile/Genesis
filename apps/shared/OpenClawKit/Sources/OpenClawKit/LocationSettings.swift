import Foundation

public enum genesisLocationMode: String, Codable, Sendable, CaseIterable {
    case off
    case whileUsing
    case always
}
