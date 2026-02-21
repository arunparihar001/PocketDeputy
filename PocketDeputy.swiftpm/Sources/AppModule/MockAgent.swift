// MockAgent.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// A rule-based offline mock agent that proposes a ToolCall based on input text.
// Intentionally "LLM-ish": it is occasionally over-eager (e.g., sees "reply"
// and immediately proposes composeMessage) to illustrate why a gateway is needed.
// NO network calls are made anywhere in this file.

import Foundation

// MARK: - MockAgent

struct MockAgent {

    // MARK: Public API

    /// Analyse the input text and propose a single ToolCall.
    /// - Parameters:
    ///   - input: The raw text received from the channel.
    ///   - channel: The channel provenance (used for context, not decisions).
    /// - Returns: A proposed `ToolCall` (never nil – the agent always proposes something).
    func propose(input: String, channel: Channel) -> ToolCall {
        let lower = input.lowercased()

        // 1. URL-like input → openURL
        if let url = extractURL(from: input) {
            return ToolCall(tool: .openURL, args: ["url": url])
        }

        // 2. Compose / reply cues (over-eager LLM behaviour)
        if containsAny(lower, keywords: ["reply", "send message", "compose", "email", "respond to", "confirm"]) {
            let recipient = extractEmail(from: input) ?? extractHandle(from: input) ?? "unknown@example.com"
            let body = extractQuotedText(from: input) ?? trimmed(input, maxLen: 80)
            return ToolCall(tool: .composeMessage, args: ["to": recipient, "body": body])
        }

        // 3. Calendar reminder cues
        if containsAny(lower, keywords: ["reminder", "remind me", "schedule", "calendar", "set an event", "wwdc", "keynote", "meeting"]) {
            let title = extractQuotedText(from: input) ?? trimmed(input, maxLen: 60)
            let date  = extractISODate(from: input) ?? nearFutureISO()
            return ToolCall(tool: .createCalendarReminder, args: ["title": title, "dateISO": date])
        }

        // 4. Save / note cues
        if containsAny(lower, keywords: ["save", "note", "remember", "cheat sheet", "jot down", "store"]) {
            return ToolCall(tool: .saveLocalNote, args: ["content": trimmed(input, maxLen: 120)])
        }

        // 5. Clipboard channel default (over-eager copy-to-clipboard)
        if channel == .clipboard {
            return ToolCall(tool: .copyToClipboard, args: ["text": trimmed(input, maxLen: 120)])
        }

        // 6. Fallback – save as local note
        return ToolCall(tool: .saveLocalNote, args: ["content": trimmed(input, maxLen: 120)])
    }

    // MARK: Helpers

    private func containsAny(_ text: String, keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    /// Extracts the first http/https/pocketdeputy:// URL found in the text.
    private func extractURL(from text: String) -> String? {
        // Check if the ENTIRE text is a bare URL (no spaces)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") || trimmed.hasPrefix("pocketdeputy://") {
            if !trimmed.contains(" ") { return trimmed }
        }
        // Find embedded URLs
        let pattern = "(https?://|pocketdeputy://)[^\\s]+"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }

    private func extractEmail(from text: String) -> String? {
        let pattern = "[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }

    private func extractHandle(from text: String) -> String? {
        // Match things like "to john" or "to @jane"
        let pattern = "(?:to|for)\\s+@?([A-Za-z0-9_]+)"
        if let range = text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
            // Return the capture group by splitting
            let matched = String(text[range])
            let parts = matched.split(separator: " ", maxSplits: 1)
            if parts.count == 2 { return String(parts[1]).replacingOccurrences(of: "@", with: "") }
        }
        return nil
    }

    /// Extracts text between the first pair of single or double quotes.
    private func extractQuotedText(from text: String) -> String? {
        let patterns = ["\"([^\"]+)\"", "'([^']+)'"]
        for pattern in patterns {
            if let range = text.range(of: pattern, options: .regularExpression) {
                var result = String(text[range])
                result.removeFirst(); result.removeLast()  // strip quotes
                return result
            }
        }
        return nil
    }

    /// Extracts the first ISO-8601 date string from the text.
    private func extractISODate(from text: String) -> String? {
        let pattern = "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z?"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }

    private func nearFutureISO() -> String {
        let formatter = ISO8601DateFormatter()
        let future = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return formatter.string(from: future)
    }

    private func trimmed(_ text: String, maxLen: Int) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.count > maxLen ? String(t.prefix(maxLen)) + "…" : t
    }
}
