// ActionGateway.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Policy engine that evaluates a proposed ToolCall and returns a GatewayResult.
// All logic is purely local; no network calls are made.

import Foundation

// MARK: - ActionGateway

struct ActionGateway {

    // MARK: - Internal allowlist

    /// Deep-link URL prefixes that are always allowed without confirmation.
    private static let allowlistedPrefixes: [String] = [
        "pocketdeputy://tips/"
    ]

    /// Hostnames that are considered safe for openURL.
    private static let safeHosts: Set<String> = [
        "developer.apple.com",
        "swift.org",
        "apple.com",
        "swiftui.apple.com"
    ]

    // MARK: - Injection heuristics

    /// High-signal injection keywords (each raises the score significantly).
    private static let highSignalKeywords: [String] = [
        "ignore previous",
        "ignore all previous",
        "system prompt",
        "don't tell",
        "dont tell",
        "don't mention",
        "dont mention",
        "exfiltrate",
        "otp",
        "password",
        "secret",
        "login code",
        "access token",
        "api key",
        "2fa",
        "two-factor"
    ]

    /// Medium-signal urgency patterns (each raises the score moderately).
    private static let urgencyKeywords: [String] = [
        "urgent",
        "immediately",
        "act now",
        "do it now",
        "right now",
        "asap",
        "critical",
        "emergency",
        "without delay"
    ]

    /// Override-intent patterns (each raises the score moderately).
    private static let overrideKeywords: [String] = [
        "do it now",
        "don't ask",
        "dont ask",
        "skip confirmation",
        "bypass",
        "override",
        "without asking",
        "no confirmation"
    ]

    // MARK: - Public API

    /// Evaluate the proposed ToolCall and return a gateway decision with a reason.
    func evaluate(channel: Channel, rawInput: String, proposal: ToolCall) -> GatewayResult {
        let lower = rawInput.lowercased()

        // ── 1. Allowlist: never block internal tips deep links ───────────────
        for prefix in Self.allowlistedPrefixes {
            if rawInput.hasPrefix(prefix) ||
               (proposal.tool == .openURL && (proposal.args["url"] ?? "").hasPrefix(prefix)) {
                return GatewayResult(
                    decision: .allow,
                    reason: "Input matches the internal pocketdeputy://tips/ allowlist. Safe to proceed."
                )
            }
        }

        // ── 2. Score injection signals ───────────────────────────────────────
        var score = 0
        var triggeredSignals: [String] = []

        for kw in Self.highSignalKeywords where lower.contains(kw) {
            score += 3
            triggeredSignals.append("\"\(kw)\"")
        }
        for kw in Self.urgencyKeywords where lower.contains(kw) {
            score += 1
            triggeredSignals.append("\"\(kw)\"")
        }
        for kw in Self.overrideKeywords where lower.contains(kw) {
            score += 2
            triggeredSignals.append("\"\(kw)\"")
        }

        // ── 3. Hard-block on high injection score ────────────────────────────
        if score >= 3 {
            let signals = triggeredSignals.prefix(3).joined(separator: ", ")
            return GatewayResult(
                decision: .block,
                reason: "High injection-risk score (\(score)). Detected: \(signals)."
            )
        }

        // ── 4. Per-tool rules ────────────────────────────────────────────────
        switch proposal.tool {

        case .openURL:
            return evaluateOpenURL(channel: channel, proposal: proposal, injectionScore: score)

        case .composeMessage:
            return evaluateComposeMessage(channel: channel, injectionScore: score)

        case .createCalendarReminder:
            return evaluateCalendarReminder(channel: channel, injectionScore: score)

        case .copyToClipboard:
            // Clipboard-to-clipboard overwrite needs confirmation
            if channel == .clipboard {
                return GatewayResult(
                    decision: .confirm,
                    reason: "Clipboard overwrite from a clipboard-sourced input. Please confirm."
                )
            }
            return GatewayResult(decision: .allow, reason: "Low-risk clipboard write from a non-clipboard channel.")

        case .saveLocalNote:
            // Saving a note is generally safe; confirm only if any injection signal was found
            if score > 0 {
                return GatewayResult(
                    decision: .confirm,
                    reason: "Mild injection signal (\(score)) detected in note content. Please review."
                )
            }
            return GatewayResult(decision: .allow, reason: "saveLocalNote is low-risk and no injection signals detected.")
        }
    }

    // MARK: - Per-tool evaluators

    private func evaluateOpenURL(channel: Channel, proposal: ToolCall, injectionScore: Int) -> GatewayResult {
        let urlString = proposal.args["url"] ?? ""

        // Allowlisted tip pages are always fine
        for prefix in Self.allowlistedPrefixes where urlString.hasPrefix(prefix) {
            return GatewayResult(decision: .allow, reason: "URL is on the internal pocketdeputy://tips/ allowlist.")
        }

        // Extract host for safety check
        let host = URL(string: urlString)?.host?.lowercased() ?? ""
        let isSafeHost = Self.safeHosts.contains(where: { host == $0 || host.hasSuffix(".\($0)") })

        // Safe-listed hosts are allowed regardless of channel trust when no injection signal present
        if isSafeHost && injectionScore == 0 {
            return GatewayResult(decision: .allow, reason: "URL host \"\(host)\" is on the safe-list with no injection signals.")
        }

        if isSafeHost && injectionScore > 0 {
            return GatewayResult(decision: .confirm, reason: "Safe host but mild injection signal detected. Please review.")
        }

        // Unknown / unsafe host
        if injectionScore > 0 {
            return GatewayResult(decision: .block, reason: "Unknown host \"\(host)\" combined with injection signals. Blocked.")
        }
        return GatewayResult(decision: .confirm, reason: "URL host \"\(host)\" is not on the safe-list. Please confirm before navigating.")
    }

    private func evaluateComposeMessage(channel: Channel, injectionScore: Int) -> GatewayResult {
        // composeMessage from low-trust always needs confirmation
        if channel.trustLevel == .low {
            if injectionScore > 0 {
                return GatewayResult(
                    decision: .block,
                    reason: "composeMessage from a low-trust channel (\(channel.rawValue)) with injection signals. Blocked."
                )
            }
            return GatewayResult(
                decision: .confirm,
                reason: "Outbound message proposed from low-trust \(channel.rawValue) channel. Please confirm the recipient and content."
            )
        }
        // Medium trust: confirm unless pristine
        return GatewayResult(
            decision: .confirm,
            reason: "composeMessage requires explicit user confirmation regardless of trust level."
        )
    }

    private func evaluateCalendarReminder(channel: Channel, injectionScore: Int) -> GatewayResult {
        if injectionScore > 0 || channel.trustLevel == .low {
            if injectionScore >= 2 || (injectionScore > 0 && channel.trustLevel == .low) {
                return GatewayResult(
                    decision: .block,
                    reason: "createCalendarReminder blocked: injection signal in reminder title from low-trust source."
                )
            }
            return GatewayResult(
                decision: .confirm,
                reason: "createCalendarReminder from low-trust channel. Please verify the title and date."
            )
        }
        // Medium/high trust, no signals
        return GatewayResult(decision: .allow, reason: "createCalendarReminder from a trusted channel with no injection signals.")
    }
}
