import CoreLocation
import Foundation
import genesisKit
import UIKit

protocol CameraServicing: Sendable {
    func listDevices() async -> [CameraController.CameraDeviceInfo]
    func snap(params: genesisCameraSnapParams) async throws -> (format: String, base64: String, width: Int, height: Int)
    func clip(params: genesisCameraClipParams) async throws -> (format: String, base64: String, durationMs: Int, hasAudio: Bool)
}

protocol ScreenRecordingServicing: Sendable {
    func record(
        screenIndex: Int?,
        durationMs: Int?,
        fps: Double?,
        includeAudio: Bool?,
        outPath: String?) async throws -> String
}

@MainActor
protocol LocationServicing: Sendable {
    func authorizationStatus() -> CLAuthorizationStatus
    func accuracyAuthorization() -> CLAccuracyAuthorization
    func ensureAuthorization(mode: genesisLocationMode) async -> CLAuthorizationStatus
    func currentLocation(
        params: genesisLocationGetParams,
        desiredAccuracy: genesisLocationAccuracy,
        maxAgeMs: Int?,
        timeoutMs: Int?) async throws -> CLLocation
    func startLocationUpdates(
        desiredAccuracy: genesisLocationAccuracy,
        significantChangesOnly: Bool) -> AsyncStream<CLLocation>
    func stopLocationUpdates()
    func startMonitoringSignificantLocationChanges(onUpdate: @escaping @Sendable (CLLocation) -> Void)
    func stopMonitoringSignificantLocationChanges()
}

protocol DeviceStatusServicing: Sendable {
    func status() async throws -> genesisDeviceStatusPayload
    func info() -> genesisDeviceInfoPayload
}

protocol PhotosServicing: Sendable {
    func latest(params: genesisPhotosLatestParams) async throws -> genesisPhotosLatestPayload
}

protocol ContactsServicing: Sendable {
    func search(params: genesisContactsSearchParams) async throws -> genesisContactsSearchPayload
    func add(params: genesisContactsAddParams) async throws -> genesisContactsAddPayload
}

protocol CalendarServicing: Sendable {
    func events(params: genesisCalendarEventsParams) async throws -> genesisCalendarEventsPayload
    func add(params: genesisCalendarAddParams) async throws -> genesisCalendarAddPayload
}

protocol RemindersServicing: Sendable {
    func list(params: genesisRemindersListParams) async throws -> genesisRemindersListPayload
    func add(params: genesisRemindersAddParams) async throws -> genesisRemindersAddPayload
}

protocol MotionServicing: Sendable {
    func activities(params: genesisMotionActivityParams) async throws -> genesisMotionActivityPayload
    func pedometer(params: genesisPedometerParams) async throws -> genesisPedometerPayload
}

struct WatchMessagingStatus: Sendable, Equatable {
    var supported: Bool
    var paired: Bool
    var appInstalled: Bool
    var reachable: Bool
    var activationState: String
}

struct WatchQuickReplyEvent: Sendable, Equatable {
    var replyId: String
    var promptId: String
    var actionId: String
    var actionLabel: String?
    var sessionKey: String?
    var note: String?
    var sentAtMs: Int?
    var transport: String
}

struct WatchNotificationSendResult: Sendable, Equatable {
    var deliveredImmediately: Bool
    var queuedForDelivery: Bool
    var transport: String
}

protocol WatchMessagingServicing: AnyObject, Sendable {
    func status() async -> WatchMessagingStatus
    func setReplyHandler(_ handler: (@Sendable (WatchQuickReplyEvent) -> Void)?)
    func sendNotification(
        id: String,
        params: genesisWatchNotifyParams) async throws -> WatchNotificationSendResult
}

extension CameraController: CameraServicing {}
extension ScreenRecordService: ScreenRecordingServicing {}
extension LocationService: LocationServicing {}
