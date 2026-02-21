// Models.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Core data types shared across the app.

import Foundation

// MARK: - Channel (provenance / trust level)

/// The channel through which the agent received its input.
enum Channel: String, CaseIterable, Identifiable, Codable {
    case notification = "Notification"
    case deepLink     = "Deep Link"
    case qrText       = "QR Text"
    case clipboard    = "Clipboard"

    var id: String { rawValue }

    /// Higher trust = less aggressive gating.
    var trustLevel: TrustLevel {
        switch self {
        case .deepLink: return .medium
        default:        return .low
        }
    }
}

enum TrustLevel: String, Codable {
    case low, medium, high
}

// MARK: - Tools

/// All simulated tool names the agent can propose.
enum ToolName: String, CaseIterable, Codable {
    case openURL                = "openURL"
    case composeMessage         = "composeMessage"
    case copyToClipboard        = "copyToClipboard"
    case saveLocalNote          = "saveLocalNote"
    case createCalendarReminder = "createCalendarReminder"  // ← custom extra tool

    /// Inherent risk of the tool independent of context.
    var baseRisk: RiskLevel {
        switch self {
        case .openURL:                return .medium
        case .composeMessage:         return .high
        case .copyToClipboard:        return .low
        case .saveLocalNote:          return .low
        case .createCalendarReminder: return .medium
        }
    }

    var icon: String {
        switch self {
        case .openURL:                return "safari"
        case .composeMessage:         return "message"
        case .copyToClipboard:        return "doc.on.clipboard"
        case .saveLocalNote:          return "note.text"
        case .createCalendarReminder: return "calendar.badge.plus"
        }
    }
}

enum RiskLevel: String, Codable {
    case low, medium, high
}

/// A proposed tool invocation from the agent.
struct ToolCall: Equatable, Codable {
    let tool: ToolName
    /// Key-value arguments (all strings for simplicity).
    let args: [String: String]

    var displayArgs: String {
        args.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", ")
    }
}

// MARK: - Gateway

/// The Action Gateway decision.
enum GatewayDecision: String, Codable {
    case allow   = "Allow"
    case confirm = "Confirm"
    case block   = "Block"

    var color: String {
        switch self {
        case .allow:   return "green"
        case .confirm: return "orange"
        case .block:   return "red"
        }
    }

    var icon: String {
        switch self {
        case .allow:   return "checkmark.circle.fill"
        case .confirm: return "questionmark.circle.fill"
        case .block:   return "xmark.circle.fill"
        }
    }
}

/// Full output from the Action Gateway.
struct GatewayResult: Codable {
    let decision: GatewayDecision
    let reason: String
}

// MARK: - Evidence

/// One complete evidence record for a single agent run.
struct Evidence: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let channel: Channel
    let rawInput: String
    let agentProposal: ToolCall
    let gatewayResult: GatewayResult
    /// What happened after the gateway decision (user confirmation or auto-execute).
    var finalOutcome: FinalOutcome
    /// Human-readable result from simulated tool execution.
    var toolResult: String
    /// Optional expected decision used for benchmark accuracy scoring.
    var expectedDecision: GatewayDecision?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        channel: Channel,
        rawInput: String,
        agentProposal: ToolCall,
        gatewayResult: GatewayResult,
        finalOutcome: FinalOutcome = .pending,
        toolResult: String = "",
        expectedDecision: GatewayDecision? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.channel = channel
        self.rawInput = rawInput
        self.agentProposal = agentProposal
        self.gatewayResult = gatewayResult
        self.finalOutcome = finalOutcome
        self.toolResult = toolResult
        self.expectedDecision = expectedDecision
    }
}

enum FinalOutcome: String, Codable {
    case pending    = "Pending"
    case executed   = "Executed"
    case userDenied = "User Denied"
    case blocked    = "Blocked"
}

// MARK: - Scenario

/// A built-in test scenario with a predefined input and expected gateway decision.
struct Scenario: Identifiable, Hashable {
    let id: UUID
    let name: String
    let channel: Channel
    /// The editable input text pre-loaded into the simulator.
    let inputText: String
    let expectedDecision: GatewayDecision
    /// Short description of why this scenario is interesting.
    let notes: String

    init(
        id: UUID = UUID(),
        name: String,
        channel: Channel,
        inputText: String,
        expectedDecision: GatewayDecision,
        notes: String
    ) {
        self.id = id
        self.name = name
        self.channel = channel
        self.inputText = inputText
        self.expectedDecision = expectedDecision
        self.notes = notes
    }
}
