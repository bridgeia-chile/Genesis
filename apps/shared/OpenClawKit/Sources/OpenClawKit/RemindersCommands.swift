import Foundation

public enum genesisRemindersCommand: String, Codable, Sendable {
    case list = "reminders.list"
    case add = "reminders.add"
}

public enum genesisReminderStatusFilter: String, Codable, Sendable {
    case incomplete
    case completed
    case all
}

public struct genesisRemindersListParams: Codable, Sendable, Equatable {
    public var status: genesisReminderStatusFilter?
    public var limit: Int?

    public init(status: genesisReminderStatusFilter? = nil, limit: Int? = nil) {
        self.status = status
        self.limit = limit
    }
}

public struct genesisRemindersAddParams: Codable, Sendable, Equatable {
    public var title: String
    public var dueISO: String?
    public var notes: String?
    public var listId: String?
    public var listName: String?

    public init(
        title: String,
        dueISO: String? = nil,
        notes: String? = nil,
        listId: String? = nil,
        listName: String? = nil)
    {
        self.title = title
        self.dueISO = dueISO
        self.notes = notes
        self.listId = listId
        self.listName = listName
    }
}

public struct genesisReminderPayload: Codable, Sendable, Equatable {
    public var identifier: String
    public var title: String
    public var dueISO: String?
    public var completed: Bool
    public var listName: String?

    public init(
        identifier: String,
        title: String,
        dueISO: String? = nil,
        completed: Bool,
        listName: String? = nil)
    {
        self.identifier = identifier
        self.title = title
        self.dueISO = dueISO
        self.completed = completed
        self.listName = listName
    }
}

public struct genesisRemindersListPayload: Codable, Sendable, Equatable {
    public var reminders: [genesisReminderPayload]

    public init(reminders: [genesisReminderPayload]) {
        self.reminders = reminders
    }
}

public struct genesisRemindersAddPayload: Codable, Sendable, Equatable {
    public var reminder: genesisReminderPayload

    public init(reminder: genesisReminderPayload) {
        self.reminder = reminder
    }
}
