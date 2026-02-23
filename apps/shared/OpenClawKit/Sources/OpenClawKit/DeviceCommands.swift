import Foundation

public enum genesisDeviceCommand: String, Codable, Sendable {
    case status = "device.status"
    case info = "device.info"
}

public enum genesisBatteryState: String, Codable, Sendable {
    case unknown
    case unplugged
    case charging
    case full
}

public enum genesisThermalState: String, Codable, Sendable {
    case nominal
    case fair
    case serious
    case critical
}

public enum genesisNetworkPathStatus: String, Codable, Sendable {
    case satisfied
    case unsatisfied
    case requiresConnection
}

public enum genesisNetworkInterfaceType: String, Codable, Sendable {
    case wifi
    case cellular
    case wired
    case other
}

public struct genesisBatteryStatusPayload: Codable, Sendable, Equatable {
    public var level: Double?
    public var state: genesisBatteryState
    public var lowPowerModeEnabled: Bool

    public init(level: Double?, state: genesisBatteryState, lowPowerModeEnabled: Bool) {
        self.level = level
        self.state = state
        self.lowPowerModeEnabled = lowPowerModeEnabled
    }
}

public struct genesisThermalStatusPayload: Codable, Sendable, Equatable {
    public var state: genesisThermalState

    public init(state: genesisThermalState) {
        self.state = state
    }
}

public struct genesisStorageStatusPayload: Codable, Sendable, Equatable {
    public var totalBytes: Int64
    public var freeBytes: Int64
    public var usedBytes: Int64

    public init(totalBytes: Int64, freeBytes: Int64, usedBytes: Int64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
    }
}

public struct genesisNetworkStatusPayload: Codable, Sendable, Equatable {
    public var status: genesisNetworkPathStatus
    public var isExpensive: Bool
    public var isConstrained: Bool
    public var interfaces: [genesisNetworkInterfaceType]

    public init(
        status: genesisNetworkPathStatus,
        isExpensive: Bool,
        isConstrained: Bool,
        interfaces: [genesisNetworkInterfaceType])
    {
        self.status = status
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.interfaces = interfaces
    }
}

public struct genesisDeviceStatusPayload: Codable, Sendable, Equatable {
    public var battery: genesisBatteryStatusPayload
    public var thermal: genesisThermalStatusPayload
    public var storage: genesisStorageStatusPayload
    public var network: genesisNetworkStatusPayload
    public var uptimeSeconds: Double

    public init(
        battery: genesisBatteryStatusPayload,
        thermal: genesisThermalStatusPayload,
        storage: genesisStorageStatusPayload,
        network: genesisNetworkStatusPayload,
        uptimeSeconds: Double)
    {
        self.battery = battery
        self.thermal = thermal
        self.storage = storage
        self.network = network
        self.uptimeSeconds = uptimeSeconds
    }
}

public struct genesisDeviceInfoPayload: Codable, Sendable, Equatable {
    public var deviceName: String
    public var modelIdentifier: String
    public var systemName: String
    public var systemVersion: String
    public var appVersion: String
    public var appBuild: String
    public var locale: String

    public init(
        deviceName: String,
        modelIdentifier: String,
        systemName: String,
        systemVersion: String,
        appVersion: String,
        appBuild: String,
        locale: String)
    {
        self.deviceName = deviceName
        self.modelIdentifier = modelIdentifier
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.locale = locale
    }
}
