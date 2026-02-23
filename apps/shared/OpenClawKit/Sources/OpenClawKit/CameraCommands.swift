import Foundation

public enum genesisCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum genesisCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum genesisCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum genesisCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct genesisCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: genesisCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: genesisCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: genesisCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: genesisCameraImageFormat? = nil,
        deviceId: String? = nil,
        delayMs: Int? = nil)
    {
        self.facing = facing
        self.maxWidth = maxWidth
        self.quality = quality
        self.format = format
        self.deviceId = deviceId
        self.delayMs = delayMs
    }
}

public struct genesisCameraClipParams: Codable, Sendable, Equatable {
    public var facing: genesisCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: genesisCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: genesisCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: genesisCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
