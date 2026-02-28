// ReplayView.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Timeline-style evidence replay showing all past agent runs.

import SwiftUI

struct ReplayView: View {
    @Environment(EvidenceStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No Evidence Yet")
                            .font(.headline)
                        Text("Run the agent at least once to see evidence here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach(store.history) { ev in
                            EvidenceCard(evidence: ev)
                                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Evidence Replay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        store.clearHistory()
                        dismiss()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// MARK: - EvidenceCard

struct EvidenceCard: View {
    let evidence: Evidence

    @MainActor
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header row: decision pill + timestamp + channel
            HStack {
                DecisionPill(decision: evidence.gatewayResult.decision)
                Spacer()
                ChannelBadge(channel: evidence.channel)
                Text(Self.dateFormatter.string(from: evidence.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Input preview
            Text(evidence.rawInput)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Divider()

            // Tool proposal
            HStack(spacing: 6) {
                Image(systemName: evidence.agentProposal.tool.icon)
                    .foregroundColor(.accentColor)
                    .font(.caption)
                Text(evidence.agentProposal.tool.rawValue)
                    .font(.caption.bold())
                Spacer()
                OutcomeBadge(outcome: evidence.finalOutcome)
            }

            // Gateway reason
            Text(evidence.gatewayResult.reason)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Expected vs actual (benchmark mode)
            if let expected = evidence.expectedDecision {
                HStack(spacing: 4) {
                    Text("Expected:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(expected.rawValue)
                        .font(.caption2.bold())
                        .foregroundColor(expected == evidence.gatewayResult.decision ? .green : .red)
                    Image(systemName: expected == evidence.gatewayResult.decision ? "checkmark" : "xmark")
                        .font(.caption2)
                        .foregroundColor(expected == evidence.gatewayResult.decision ? .green : .red)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}
