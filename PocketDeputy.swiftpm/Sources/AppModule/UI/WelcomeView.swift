// WelcomeView.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// First-run welcome sheet. Shown once, dismissed via "Start Lab".

import SwiftUI

struct WelcomeView: View {
    @Binding var hasSeenWelcome: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // ── Hero ────────────────────────────────────────────────
                    VStack(spacing: 12) {
                        Image(systemName: "shield.lefthalf.filled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.linearGradient(
                                colors: [.accentColor, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))

                        Text("PocketDeputy")
                            .font(.largeTitle.bold())

                        Text("Mobile Agent Prompt-Injection Safety Lab")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    // ── Description ─────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 14) {
                        BulletRow(icon: "1.circle.fill", color: .accentColor,
                                  text: "**Pick a channel** – the source of the agent's input (notification, QR code, deep link, or clipboard).")
                        BulletRow(icon: "2.circle.fill", color: .purple,
                                  text: "**Run the agent** – a rule-based mock LLM proposes a tool call based on the input text.")
                        BulletRow(icon: "3.circle.fill", color: .orange,
                                  text: "**See the Action Gateway decide** – Allow, Confirm, or Block based on injection-risk heuristics.")
                        BulletRow(icon: "4.circle.fill", color: .green,
                                  text: "**Replay evidence** and run a mini benchmark across all 12 built-in scenarios.")
                    }
                    .padding(.horizontal, 24)

                    // ── Disclaimer ───────────────────────────────────────────
                    Text("Everything runs offline. No real messages, URLs, or calendar events are created.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // ── CTA ──────────────────────────────────────────────────
                    Button {
                        hasSeenWelcome = true
                    } label: {
                        Text("Start Lab")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Helper

private struct BulletRow: View {
    let icon: String
    let color: Color
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
