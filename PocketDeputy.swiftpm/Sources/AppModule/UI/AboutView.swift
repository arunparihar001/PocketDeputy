// AboutView.swift
// PocketDeputy: Mobile Agent Prompt-Injection Safety Lab
//
// Disclosure, personalization checklist, and credits.
//
// HOW TO RUN IN XCODE:
//   1. Open PocketDeputy.swiftpm in Xcode (drag the folder or double-click Package.swift).
//   2. Select any iOS 16+ simulator (e.g., iPhone 15 Pro).
//   3. Press ▶ – no additional setup required.
//
// HOW TO ZIP FOR SUBMISSION:
//   In Terminal: zip -r PocketDeputy.swiftpm.zip PocketDeputy.swiftpm
//
// WHAT YOU MUST PERSONALISE BEFORE SUBMITTING:
//   1. Rewrite scenario texts in Scenarios.swift.
//   2. Fill in the AI tool usage disclosure below.
//   3. Optionally tweak gateway rules in ActionGateway.swift and explain the
//      design tradeoffs in your written submission.

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            List {

                // ── Why it matters ───────────────────────────────────────────
                Section("Why It Matters") {
                    BulletPoint(icon: "exclamationmark.triangle.fill", color: .orange,
                                text: "Mobile AI agents act on user behalf via SMS, URL-open, and calendar APIs. A single prompt-injection can silently exfiltrate data or send messages.")
                    BulletPoint(icon: "lock.shield.fill", color: .accentColor,
                                text: "An Action Gateway adds a policy layer between the LLM output and real-world side effects, reducing attack surface regardless of model quality.")
                    BulletPoint(icon: "checkmark.seal.fill", color: .green,
                                text: "Input provenance (channel trust level) matters. A QR code from an unknown vendor is fundamentally less trustworthy than a user's own deep link.")
                    BulletPoint(icon: "eye.trianglebadge.exclamationmark.fill", color: .red,
                                text: "Prompt injection is often invisible to users. Explicit confirmation prompts make the agent's proposed actions auditable and reversible.")
                }

                // ── Offline disclaimer ───────────────────────────────────────
                Section("Offline Disclaimer") {
                    Text("PocketDeputy is fully offline. No network requests are made. No real SMS, calendar events, clipboard writes, or URL navigations occur. All tool executions are simulated and logged only in memory.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // ── AI tool usage disclosure ─────────────────────────────────
                Section("AI Tool Usage Disclosure") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TODO: Fill in this section before submitting.")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                        Text("""
This playground was developed with assistance from AI coding tools. \
[REPLACE: describe which tools you used, how you used them, what you wrote \
yourself vs. what was AI-generated, and how you reviewed and validated the \
AI-generated code.]
""")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }

                // ── Personalisation checklist ────────────────────────────────
                Section("Personalization Checklist") {
                    VStack(alignment: .leading, spacing: 12) {
                        CheckItem(number: 1,
                                  text: "Rewrite all scenario texts in **Scenarios.swift** with your own wording. At least 12 scenarios must exist; you should also add 2 of your own on top.")
                        CheckItem(number: 2,
                                  text: "Review and modify the gateway rules in **ActionGateway.swift**. Be ready to explain the design tradeoffs (false positives vs. false negatives) in your written submission.")
                        CheckItem(number: 3,
                                  text: "Add a small extra UI polish: a custom app icon, a colour scheme, or your own copy on the Welcome screen.")
                        CheckItem(number: 4,
                                  text: "Fill in the AI Tool Usage Disclosure above with an honest description of how AI tools assisted you.")
                    }
                    .padding(.vertical, 4)
                }

                // ── Credits ──────────────────────────────────────────────────
                Section("Credits") {
                    Text("PocketDeputy scaffold generated as a Swift Student Challenge submission template. All scenario texts are placeholder defaults – you are expected to replace them with your own content before submitting.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Built with SwiftUI · iOS 16+ · Fully offline · No third-party dependencies.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helpers

private struct BulletPoint: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct CheckItem: View {
    let number: Int
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Circle())
                .foregroundColor(.accentColor)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
