// EvidenceStore.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Central @Observable store that holds all evidence records and orchestrates
// the agent → gateway → simulated-execution pipeline.
// Everything runs on the MainActor; no network calls are made.

import SwiftUI
import Observation

@Observable
@MainActor
final class EvidenceStore {

    // MARK: - Observable state

    var history: [Evidence] = []
    var lastEvidence: Evidence?
    var isRunning: Bool = false

    // MARK: - Dependencies

    private let agent   = MockAgent()
    private let gateway = ActionGateway()

    // MARK: - Run pipeline

    /// Execute the full agent → gateway pipeline for the given input.
    func run(input: String, channel: Channel, expectedDecision: GatewayDecision? = nil) {
        isRunning = true
        defer { isRunning = false }

        // 1. Agent proposes a tool call
        let proposal = agent.propose(input: input, channel: channel)

        // 2. Gateway evaluates the proposal
        let gatewayResult = gateway.evaluate(channel: channel, rawInput: input, proposal: proposal)

        // 3. Determine initial final outcome
        let initialOutcome: FinalOutcome
        switch gatewayResult.decision {
        case .allow:   initialOutcome = .executed
        case .confirm: initialOutcome = .pending
        case .block:   initialOutcome = .blocked
        }

        // 4. Simulate immediate execution for auto-allowed calls
        var toolResult = ""
        if gatewayResult.decision == .allow {
            toolResult = simulatedToolResult(for: proposal)
        }

        // 5. Build evidence record
        var evidence = Evidence(
            channel: channel,
            rawInput: input,
            agentProposal: proposal,
            gatewayResult: gatewayResult,
            finalOutcome: initialOutcome,
            toolResult: toolResult,
            expectedDecision: expectedDecision
        )

        // 6. Store
        history.insert(evidence, at: 0)
        lastEvidence = evidence
    }

    // MARK: - User confirmation (called from UI)

    /// Called when the user taps "Confirm (simulate user approval)".
    /// Finds the matching evidence record, executes the simulated tool, and updates state.
    func confirmExecution(evidenceID: UUID) {
        guard let idx = history.firstIndex(where: { $0.id == evidenceID }) else { return }
        let result = simulatedToolResult(for: history[idx].agentProposal)
        history[idx].finalOutcome = .executed
        history[idx].toolResult   = result
        if lastEvidence?.id == evidenceID { lastEvidence = history[idx] }
    }

    /// Called when the user taps "Deny" for a confirm-gated action.
    func denyExecution(evidenceID: UUID) {
        guard let idx = history.firstIndex(where: { $0.id == evidenceID }) else { return }
        history[idx].finalOutcome = .userDenied
        history[idx].toolResult   = "User denied the action."
        if lastEvidence?.id == evidenceID { lastEvidence = history[idx] }
    }

    // MARK: - Simulated tool execution

    /// Returns a human-readable description of what the tool *would* do.
    /// NO real actions are performed (no URL open, no SMS, no clipboard write, etc.).
    func simulatedToolResult(for call: ToolCall) -> String {
        switch call.tool {
        case .openURL:
            let url = call.args["url"] ?? "(no url)"
            return "[Simulated] Would open URL: \(url)"

        case .composeMessage:
            let to   = call.args["to"]   ?? "(unknown)"
            let body = call.args["body"] ?? "(empty)"
            return "[Simulated] Would send message to \(to): \"\(body)\""

        case .copyToClipboard:
            let text = call.args["text"] ?? "(empty)"
            return "[Simulated] Would copy to clipboard: \"\(text)\""

        case .saveLocalNote:
            let content = call.args["content"] ?? "(empty)"
            return "[Simulated] Local note saved: \"\(content)\""

        case .createCalendarReminder:
            let title = call.args["title"]   ?? "(no title)"
            let date  = call.args["dateISO"] ?? "(no date)"
            return "[Simulated] Would create calendar reminder \"\(title)\" at \(date)"
        }
    }

    // MARK: - Convenience

    var isEmpty: Bool { history.isEmpty }

    func clearHistory() { history.removeAll(); lastEvidence = nil }
}
