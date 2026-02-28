// SimulatorView.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Main interactive lab screen.
// Flow: pick channel → pick/edit scenario text → Run Agent → see result → optionally confirm.

import SwiftUI

struct SimulatorView: View {
    @Environment(EvidenceStore.self) private var store

    // ── Picker state ─────────────────────────────────────────────────────────
    @State private var selectedChannel: Channel = .notification
    @State private var selectedScenario: Scenario? = nil
    @State private var inputText: String = ""
    @State private var showReplay: Bool = false

    // Derived: scenarios for the selected channel
    private var channelScenarios: [Scenario] {
        Scenarios.scenarios(for: selectedChannel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    // ── Channel picker ───────────────────────────────────────
                    SectionCard(title: "Input Channel", icon: "antenna.radiowaves.left.and.right") {
                        Picker("Channel", selection: $selectedChannel) {
                            ForEach(Channel.allCases) { ch in
                                Text(ch.rawValue).tag(ch)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedChannel) { _, _ in
                            selectedScenario = nil
                            inputText = ""
                        }

                        HStack {
                            Text("Trust:").font(.caption).foregroundColor(.secondary)
                            Text(selectedChannel.trustLevel.rawValue.capitalized)
                                .font(.caption.bold())
                                .foregroundColor(selectedChannel.trustLevel == .medium ? .orange : .red)
                        }
                    }

                    // ── Scenario picker ──────────────────────────────────────
                    SectionCard(title: "Scenario", icon: "list.bullet.rectangle") {
                        if channelScenarios.isEmpty {
                            Text("No scenarios for this channel.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Picker("Scenario", selection: $selectedScenario) {
                                Text("Custom input").tag(Optional<Scenario>.none)
                                ForEach(channelScenarios) { s in
                                    Text(s.name).tag(Optional(s))
                                }
                            }
                            .onChange(of: selectedScenario) { _, s in
                                if let s { inputText = s.inputText }
                            }
                        }
                        if let s = selectedScenario {
                            Text(s.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                    }

                    // ── Input text editor ────────────────────────────────────
                    SectionCard(title: "Agent Input Text", icon: "text.alignleft") {
                        TextEditor(text: $inputText)
                            .frame(minHeight: 100)
                            .font(.body)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.secondary.opacity(0.3))
                            )
                            .cornerRadius(8)
                        Text("Edit freely to craft your own injection attempt.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // ── Run button ───────────────────────────────────────────
                    Button {
                        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        store.run(
                            input: inputText,
                            channel: selectedChannel,
                            expectedDecision: selectedScenario?.expectedDecision
                        )
                    } label: {
                        HStack {
                            if store.isRunning {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text("Run Agent")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.secondary : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isRunning)

                    // ── Results ──────────────────────────────────────────────
                    if let ev = store.lastEvidence {
                        ResultPanel(evidence: ev)
                    }

                    // ── Replay link ──────────────────────────────────────────
                    if !store.isEmpty {
                        Button {
                            showReplay = true
                        } label: {
                            Label("View Evidence History (\(store.history.count))", systemImage: "clock.arrow.circlepath")
                                .font(.subheadline)
                        }
                        .sheet(isPresented: $showReplay) {
                            ReplayView()
                                .environment(store)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("PocketDeputy Lab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - ResultPanel

private struct ResultPanel: View {
    @Environment(EvidenceStore.self) private var store
    let evidence: Evidence

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            LabelledDivider(label: "LAST RUN")

            // Proposed tool call
            SectionCard(title: "Agent Proposal", icon: "cpu") {
                ToolCallRow(call: evidence.agentProposal)
            }

            // Gateway decision
            SectionCard(title: "Action Gateway", icon: "shield.checkered") {
                HStack {
                    DecisionPill(decision: evidence.gatewayResult.decision)
                    Spacer()
                    ChannelBadge(channel: evidence.channel)
                }
                Text(evidence.gatewayResult.reason)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Confirm/Deny buttons (only when pending)
            if evidence.finalOutcome == .pending {
                HStack(spacing: 12) {
                    Button {
                        store.confirmExecution(evidenceID: evidence.id)
                    } label: {
                        Label("Confirm (simulate approval)", systemImage: "checkmark")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(10)
                    }

                    Button {
                        store.denyExecution(evidenceID: evidence.id)
                    } label: {
                        Label("Deny", systemImage: "xmark")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                }
            }

            // Final outcome + tool result
            SectionCard(title: "Simulated Outcome", icon: "checkmark.seal") {
                OutcomeBadge(outcome: evidence.finalOutcome)
                if !evidence.toolResult.isEmpty {
                    Text(evidence.toolResult)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
    }
}
